note
	description: "Kubernetes API facade - main entry point for simple_k8s library"
	author: "Larry Rix"
	usage: "[
		-- Create client (auto-detects kubeconfig or in-cluster)
		create k8s.make
		
		-- Use client directly
		if attached k8s.client.list_pods ('default') as json then
			print (json)
		end
		
		-- Use kubectl-like quick API
		k8s.kubectl.run ('nginx', 'nginx:alpine')
		k8s.kubectl.scale ('my-deployment', 3)
		
		-- Type references for anchored types
		local
			l_pod: like k8s.pod_spec_typeref
		do
			create l_pod.make
			l_pod := l_pod.set_name ('my-pod').set_image ('nginx')
		end
	]"

class
	SIMPLE_K8S

create
	make,
	make_from_file,
	make_in_cluster

feature {NONE} -- Initialization

	make
			-- Create with auto-detected config (in-cluster or kubeconfig).
		do
			create client.make
			create kubectl.make (client)
		ensure
			client_created: client /= Void
			kubectl_created: kubectl /= Void
		end

	make_from_file (a_path: STRING)
			-- Create from specific kubeconfig file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_config: K8S_CONFIG
		do
			create l_config.make_from_file (a_path)
			create client.make_with_config (l_config)
			create kubectl.make (client)
		ensure
			client_created: client /= Void
		end

	make_in_cluster
			-- Create for in-cluster usage (uses service account).
		local
			l_config: K8S_CONFIG
		do
			create l_config.make_in_cluster
			create client.make_with_config (l_config)
			create kubectl.make (client)
		ensure
			client_created: client /= Void
		end

feature -- Access

	client: K8S_CLIENT
			-- Low-level Kubernetes API client.

	kubectl: KUBECTL_QUICK
			-- kubectl-like convenience API.

feature -- Status

	is_configured: BOOLEAN
			-- Is client properly configured?
		do
			Result := client.is_configured
		end

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := client.has_error
		end

	error_message: STRING
			-- Human-readable error message.
		do
			Result := client.error_message
		ensure
			result_not_void: Result /= Void
		end

feature -- Quick Operations (delegates to kubectl)

	run (a_name, a_image: STRING): detachable STRING
			-- Create pod (like kubectl run).
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
		do
			Result := kubectl.run (a_name, a_image)
		end

	scale (a_deployment: STRING; a_replicas: INTEGER): BOOLEAN
			-- Scale deployment (like kubectl scale).
		require
			name_not_empty: not a_deployment.is_empty
			replicas_non_negative: a_replicas >= 0
		do
			Result := kubectl.scale (a_deployment, a_replicas)
		end

	logs (a_pod: STRING): detachable STRING
			-- Get pod logs (like kubectl logs).
		require
			pod_not_empty: not a_pod.is_empty
		do
			Result := kubectl.logs (a_pod)
		end

	pods: detachable STRING
			-- List pods in current namespace.
		do
			Result := kubectl.pods
		end

	deployments: detachable STRING
			-- List deployments in current namespace.
		do
			Result := kubectl.deployments
		end

	services: detachable STRING
			-- List services in current namespace.
		do
			Result := kubectl.services
		end

	namespaces: detachable STRING
			-- List all namespaces.
		do
			Result := kubectl.namespaces
		end

feature -- Namespace Control

	use_namespace (a_namespace: STRING): like Current
			-- Change working namespace (fluent).
		require
			not_empty: not a_namespace.is_empty
		do
			kubectl.set_namespace (a_namespace)
			Result := Current
		ensure
			namespace_changed: kubectl.namespace.same_string (a_namespace)
		end

	current_namespace: STRING
			-- Current working namespace.
		do
			Result := kubectl.namespace
		end

feature {NONE} -- Type references (for `like` anchors only)

	pod_spec_typeref: detachable POD_SPEC
			-- Type anchor for POD_SPEC.
		require
			type_ref_only_never_call: False
		attribute
		end

	deployment_spec_typeref: detachable DEPLOYMENT_SPEC
			-- Type anchor for DEPLOYMENT_SPEC.
		require
			type_ref_only_never_call: False
		attribute
		end

	service_spec_typeref: detachable SERVICE_SPEC
			-- Type anchor for SERVICE_SPEC.
		require
			type_ref_only_never_call: False
		attribute
		end

	service_port_typeref: detachable SERVICE_PORT
			-- Type anchor for SERVICE_PORT.
		require
			type_ref_only_never_call: False
		attribute
		end

	k8s_error_typeref: detachable K8S_ERROR
			-- Type anchor for K8S_ERROR.
		require
			type_ref_only_never_call: False
		attribute
		end

	k8s_config_typeref: detachable K8S_CONFIG
			-- Type anchor for K8S_CONFIG.
		require
			type_ref_only_never_call: False
		attribute
		end

	k8s_client_typeref: detachable K8S_CLIENT
			-- Type anchor for K8S_CLIENT.
		require
			type_ref_only_never_call: False
		attribute
		end

	kubectl_quick_typeref: detachable KUBECTL_QUICK
			-- Type anchor for KUBECTL_QUICK.
		require
			type_ref_only_never_call: False
		attribute
		end

invariant
	client_not_void: client /= Void
	kubectl_not_void: kubectl /= Void

end
