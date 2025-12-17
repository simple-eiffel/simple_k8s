note
	description: "Kubernetes API client facade"
	author: "Larry Rix"

class
	K8S_CLIENT

create
	make,
	make_with_config

feature {NONE} -- Initialization

	make
			-- Create client with default config detection.
		local
			l_config: K8S_CONFIG
		do
			create l_config.make
			-- Try in-cluster first, then kubeconfig
			if l_config.is_in_cluster_environment then
				create l_config.make_in_cluster
			elseif attached l_config.default_config_path as l_path then
				create l_config.make_from_file (l_path)
			end
			make_with_config (l_config)
		end

	make_with_config (a_config: K8S_CONFIG)
			-- Create client with specified config.
		require
			config_not_void: a_config /= Void
		do
			config := a_config
			create http.make
			create auth.make
			auth.configure_http (http, a_config)
		ensure
			config_set: config = a_config
		end

feature -- Access

	config: K8S_CONFIG
			-- Kubernetes configuration.

	last_error: detachable K8S_ERROR
			-- Last error encountered.

feature -- Status

	is_configured: BOOLEAN
			-- Is client properly configured?
		do
			Result := config.is_valid
		end

	has_error: BOOLEAN
			-- Was there an error on last operation?
		do
			Result := last_error /= Void
		end

feature -- Pod Operations

	list_pods (a_namespace: STRING): detachable STRING
			-- List pods in namespace. Returns JSON string.
		require
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/pods")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_pod (a_name, a_namespace: STRING): detachable STRING
			-- Get pod by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/pods/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	delete_pod (a_name, a_namespace: STRING): BOOLEAN
			-- Delete pod by name. Returns True on success.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/pods/" + a_name)
			l_response := http.delete (l_url)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Pod Creation

	create_pod (a_spec: POD_SPEC): detachable STRING
			-- Create pod from spec. Returns JSON string.
		require
			spec_valid: a_spec.is_valid
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_spec.namespace + "/pods")
			l_response := http.post (l_url, a_spec.to_json)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	pod_logs (a_name, a_namespace: STRING): detachable STRING
			-- Get logs from pod. Returns log text.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/pods/" + a_name + "/log")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Deployment Operations

	list_deployments (a_namespace: STRING): detachable STRING
			-- List deployments in namespace. Returns JSON string.
		require
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_namespace + "/deployments")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_deployment (a_name, a_namespace: STRING): detachable STRING
			-- Get deployment by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_namespace + "/deployments/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	scale_deployment (a_name, a_namespace: STRING; a_replicas: INTEGER): BOOLEAN
			-- Scale deployment to specified replicas.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			replicas_non_negative: a_replicas >= 0
			configured: is_configured
		local
			l_url: STRING
			l_body: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_namespace + "/deployments/" + a_name + "/scale")
			l_body := "{%"spec%":{%"replicas%":" + a_replicas.out + "}}"
			l_response := http.patch (l_url, l_body)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Deployment Creation

	create_deployment (a_spec: DEPLOYMENT_SPEC): detachable STRING
			-- Create deployment from spec. Returns JSON string.
		require
			spec_valid: a_spec.is_valid
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_spec.namespace + "/deployments")
			l_response := http.post (l_url, a_spec.to_json)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	delete_deployment (a_name, a_namespace: STRING): BOOLEAN
			-- Delete deployment by name. Returns True on success.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_namespace + "/deployments/" + a_name)
			l_response := http.delete (l_url)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	rollout_restart (a_name, a_namespace: STRING): BOOLEAN
			-- Trigger rolling restart of deployment.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_body: STRING
			l_response: SIMPLE_HTTP_RESPONSE
			l_timestamp: STRING
		do
			last_error := Void
			l_url := api_url ("/apis/apps/v1/namespaces/" + a_namespace + "/deployments/" + a_name)
			l_timestamp := (create {DATE_TIME}.make_now).out
			l_body := "{%"spec%":{%"template%":{%"metadata%":{%"annotations%":{%"kubectl.kubernetes.io/restartedAt%":%"" + l_timestamp + "%"}}}}}"
			l_response := http.patch (l_url, l_body)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end


feature -- Service Operations

	list_services (a_namespace: STRING): detachable STRING
			-- List services in namespace. Returns JSON string.
		require
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/services")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_service (a_name, a_namespace: STRING): detachable STRING
			-- Get service by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/services/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Service Creation

	create_service (a_spec: SERVICE_SPEC): detachable STRING
			-- Create service from spec. Returns JSON string.
		require
			spec_valid: a_spec.is_valid
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_spec.namespace + "/services")
			l_response := http.post (l_url, a_spec.to_json)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	delete_service (a_name, a_namespace: STRING): BOOLEAN
			-- Delete service by name. Returns True on success.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/services/" + a_name)
			l_response := http.delete (l_url)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Namespace Operations

	list_namespaces: detachable STRING
			-- List all namespaces. Returns JSON string.
		require
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_namespace (a_name: STRING): detachable STRING
			-- Get namespace by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- ConfigMap Operations

	list_configmaps (a_namespace: STRING): detachable STRING
			-- List configmaps in namespace. Returns JSON string.
		require
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/configmaps")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_configmap (a_name, a_namespace: STRING): detachable STRING
			-- Get configmap by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/configmaps/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Secret Operations

	list_secrets (a_namespace: STRING): detachable STRING
			-- List secrets in namespace. Returns JSON string.
		require
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/secrets")
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	get_secret (a_name, a_namespace: STRING): detachable STRING
			-- Get secret by name. Returns JSON string.
		require
			name_not_empty: not a_name.is_empty
			namespace_not_empty: not a_namespace.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url ("/api/v1/namespaces/" + a_namespace + "/secrets/" + a_name)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Generic Operations

	get_resource (a_path: STRING): detachable STRING
			-- Generic GET for any API path. Returns JSON string.
		require
			path_not_empty: not a_path.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url (a_path)
			l_response := http.get (l_url)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	post_resource (a_path, a_body: STRING): detachable STRING
			-- Generic POST for any API path. Returns JSON string.
		require
			path_not_empty: not a_path.is_empty
			body_not_void: a_body /= Void
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url (a_path)
			l_response := http.post (l_url, a_body)
			if l_response.is_success then
				Result := l_response.body_string
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

	delete_resource (a_path: STRING): BOOLEAN
			-- Generic DELETE for any API path.
		require
			path_not_empty: not a_path.is_empty
			configured: is_configured
		local
			l_url: STRING
			l_response: SIMPLE_HTTP_RESPONSE
		do
			last_error := Void
			l_url := api_url (a_path)
			l_response := http.delete (l_url)
			if l_response.is_success then
				Result := True
			else
				create last_error.make_from_status (l_response.status, l_response.body_string)
			end
		end

feature -- Error Access

	error_message: STRING
			-- Human-readable error message from last operation.
		do
			if attached last_error as err then
				Result := err.to_string
			else
				create Result.make_empty
			end
		ensure
			result_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	http: SIMPLE_HTTP
			-- HTTP client.

	auth: K8S_AUTH
			-- Authentication handler.

	api_url (a_path: STRING): STRING
			-- Build full API URL.
		require
			path_not_empty: not a_path.is_empty
		do
			Result := config.api_server + a_path
		ensure
			result_not_empty: not Result.is_empty
		end

invariant
	config_not_void: config /= Void
	http_not_void: http /= Void
	auth_not_void: auth /= Void

end
