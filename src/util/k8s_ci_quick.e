note
	description: "[
		CI/CD pipeline helper for Kubernetes operations.

		Provides operations designed for CI pipelines with:
		- Exit codes suitable for shell scripts
		- Wait-for-ready semantics
		- Deployment verification
		- Health checks

		Exit codes:
		- 0: Success
		- 1: General failure
		- 2: Resource not found
		- 3: Timeout waiting for condition
		- 4: Authentication/authorization failure
		- 5: Resource not ready/healthy

		Example usage in CI:
			create ci.make
			exit_code := ci.wait_for_deployment_ready ("web-app", "production", 300)
			if exit_code /= 0 then
				-- Pipeline fails
			end
	]"
	author: "Larry Rix"

class
	K8S_CI_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create CI helper with auto-configured client.
		local
			l_config: K8S_CONFIG
		do
			create l_config.make
			create client.make_with_config (l_config)
			default_namespace := "default"
			last_message := ""
		ensure
			client_exists: client /= Void
		end

feature -- Access

	client: K8S_CLIENT
			-- Underlying K8s client.

	default_namespace: STRING assign set_default_namespace
			-- Default namespace for operations.

	last_message: STRING
			-- Human-readable message from last operation.

	last_exit_code: INTEGER
			-- Exit code from last operation.

feature -- Exit Codes (Constants)

	exit_success: INTEGER = 0
			-- Operation succeeded.

	exit_failure: INTEGER = 1
			-- General failure.

	exit_not_found: INTEGER = 2
			-- Resource not found.

	exit_timeout: INTEGER = 3
			-- Timeout waiting for condition.

	exit_auth_failure: INTEGER = 4
			-- Authentication or authorization failure.

	exit_not_ready: INTEGER = 5
			-- Resource not ready or unhealthy.

feature -- Configuration

	set_default_namespace (a_namespace: STRING)
			-- Set default namespace.
		require
			not_empty: not a_namespace.is_empty
		do
			default_namespace := a_namespace
		ensure
			set: default_namespace.same_string (a_namespace)
		end

feature -- Deployment Operations

	wait_for_deployment_ready (a_name, a_namespace: STRING; a_timeout_seconds: INTEGER): INTEGER
			-- Wait for deployment to be fully available.
			-- Returns exit_success when all replicas are ready.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			timeout_positive: a_timeout_seconds > 0
		local
			l_iterations: INTEGER
			l_max_iterations: INTEGER
			l_ready: BOOLEAN
			l_deployment: K8S_DEPLOYMENT
			l_env: EXECUTION_ENVIRONMENT
		do
			create l_env
			-- Check every 2 seconds
			l_max_iterations := a_timeout_seconds // 2

			from
				l_ready := False
				l_iterations := 0
			until
				l_ready or else l_iterations > l_max_iterations
			loop
				if attached client.get_deployment (a_name, a_namespace) as json then
					create l_deployment.make_from_json (json)
					if l_deployment.is_available and then l_deployment.ready_replicas >= l_deployment.replicas then
						l_ready := True
						last_message := "Deployment " + a_name + " is ready (" + l_deployment.ready_replicas.out + "/" + l_deployment.replicas.out + " replicas)"
						Result := exit_success
					else
						l_env.sleep (2_000_000_000) -- 2 seconds
						l_iterations := l_iterations + 1
					end
				else
					if client.has_error and then attached client.last_error as err then
						if err.is_not_found then
							last_message := "Deployment " + a_name + " not found"
							Result := exit_not_found
							l_ready := True -- Exit loop
						elseif err.is_unauthorized or err.is_forbidden then
							last_message := "Access denied to deployment " + a_name
							Result := exit_auth_failure
							l_ready := True
						end
					else
						l_env.sleep (2_000_000_000)
						l_iterations := l_iterations + 1
					end
				end
			end

			if not l_ready then
				last_message := "Timeout waiting for deployment " + a_name + " after " + a_timeout_seconds.out + " seconds"
				Result := exit_timeout
			end

			last_exit_code := Result
		ensure
			valid_exit_code: Result >= 0 and Result <= 5
		end

	verify_deployment_replicas (a_name, a_namespace: STRING; a_expected_replicas: INTEGER): INTEGER
			-- Verify deployment has expected replica count.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			replicas_valid: a_expected_replicas >= 0
		local
			l_deployment: K8S_DEPLOYMENT
		do
			if attached client.get_deployment (a_name, a_namespace) as json then
				create l_deployment.make_from_json (json)
				if l_deployment.ready_replicas = a_expected_replicas then
					last_message := "Deployment " + a_name + " has " + a_expected_replicas.out + " ready replicas"
					Result := exit_success
				else
					last_message := "Deployment " + a_name + " has " + l_deployment.ready_replicas.out + " replicas, expected " + a_expected_replicas.out
					Result := exit_not_ready
				end
			else
				last_message := "Deployment " + a_name + " not found"
				Result := exit_not_found
			end
			last_exit_code := Result
		end

	scale_and_wait (a_name, a_namespace: STRING; a_replicas, a_timeout_seconds: INTEGER): INTEGER
			-- Scale deployment and wait for new replicas to be ready.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			replicas_valid: a_replicas >= 0
			timeout_positive: a_timeout_seconds > 0
		do
			if client.scale_deployment (a_name, a_namespace, a_replicas) then
				Result := wait_for_deployment_ready (a_name, a_namespace, a_timeout_seconds)
			else
				last_message := "Failed to scale deployment " + a_name
				Result := exit_failure
			end
			last_exit_code := Result
		end

	rollout_and_wait (a_name, a_namespace: STRING; a_timeout_seconds: INTEGER): INTEGER
			-- Trigger rollout restart and wait for completion.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			timeout_positive: a_timeout_seconds > 0
		do
			if client.rollout_restart (a_name, a_namespace) then
				Result := wait_for_deployment_ready (a_name, a_namespace, a_timeout_seconds)
			else
				last_message := "Failed to restart deployment " + a_name
				Result := exit_failure
			end
			last_exit_code := Result
		end

feature -- Health Checks

	check_pod_running (a_name, a_namespace: STRING): INTEGER
			-- Check if pod is running.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
		local
			l_pod: K8S_POD
		do
			if attached client.get_pod (a_name, a_namespace) as json then
				create l_pod.make_from_json (json)
				if l_pod.is_running then
					last_message := "Pod " + a_name + " is running"
					Result := exit_success
				else
					last_message := "Pod " + a_name + " is in phase: " + l_pod.phase
					Result := exit_not_ready
				end
			else
				last_message := "Pod " + a_name + " not found"
				Result := exit_not_found
			end
			last_exit_code := Result
		end

	check_namespace_active (a_name: STRING): INTEGER
			-- Check if namespace exists and is active.
		require
			name_not_empty: not a_name.is_empty
		local
			l_ns: K8S_NAMESPACE
		do
			if attached client.get_namespace (a_name) as json then
				create l_ns.make_from_json (json)
				if l_ns.is_active then
					last_message := "Namespace " + a_name + " is active"
					Result := exit_success
				else
					last_message := "Namespace " + a_name + " is " + l_ns.phase
					Result := exit_not_ready
				end
			else
				last_message := "Namespace " + a_name + " not found"
				Result := exit_not_found
			end
			last_exit_code := Result
		end

feature -- Resource Existence

	resource_exists (a_type, a_name, a_namespace: STRING): INTEGER
			-- Check if resource exists.
		require
			type_not_empty: not a_type.is_empty
			name_not_empty: not a_name.is_empty
		local
			l_json: detachable STRING
		do
			if a_type.same_string ("pod") then
				l_json := client.get_pod (a_name, a_namespace)
			elseif a_type.same_string ("deployment") then
				l_json := client.get_deployment (a_name, a_namespace)
			elseif a_type.same_string ("service") then
				l_json := client.get_service (a_name, a_namespace)
			elseif a_type.same_string ("configmap") then
				l_json := client.get_configmap (a_name, a_namespace)
			elseif a_type.same_string ("secret") then
				l_json := client.get_secret (a_name, a_namespace)
			elseif a_type.same_string ("namespace") then
				l_json := client.get_namespace (a_name)
			end

			if l_json /= Void then
				last_message := a_type + "/" + a_name + " exists"
				Result := exit_success
			else
				last_message := a_type + "/" + a_name + " not found"
				Result := exit_not_found
			end
			last_exit_code := Result
		end

feature -- Convenience

	is_cluster_reachable: INTEGER
			-- Check if cluster is reachable.
		do
			if client.is_configured then
				-- Try to list namespaces as a connectivity test
				if attached client.list_namespaces as json then
					last_message := "Cluster is reachable"
					Result := exit_success
				else
					if client.has_error and then attached client.last_error as err then
						if err.is_unauthorized or err.is_forbidden then
							last_message := "Cluster reachable but access denied"
							Result := exit_auth_failure
						else
							last_message := "Cluster connection failed: " + err.message
							Result := exit_failure
						end
					else
						last_message := "Cluster connection failed"
						Result := exit_failure
					end
				end
			else
				last_message := "No valid kubeconfig found"
				Result := exit_failure
			end
			last_exit_code := Result
		end

	print_result
			-- Print last_message to stdout (useful for CI logs).
		do
			print (last_message + "%N")
		end

invariant
	client_exists: client /= Void
	namespace_not_void: default_namespace /= Void
	namespace_not_empty: not default_namespace.is_empty
	message_not_void: last_message /= Void

end
