note
	description: "kubectl-like convenience API for quick Kubernetes operations"
	author: "Larry Rix"
	usage: "[
		-- Quick one-liner operations like kubectl CLI
		create kubectl.make (client)
		kubectl.run ("nginx", "nginx:alpine")              -- kubectl run nginx --image=nginx:alpine
		kubectl.scale ("my-deployment", 3)                 -- kubectl scale deployment my-deployment --replicas=3
		kubectl.logs ("my-pod")                            -- kubectl logs my-pod
		kubectl.delete_pod ("my-pod")                      -- kubectl delete pod my-pod
		kubectl.expose ("my-deployment", 80)               -- kubectl expose deployment my-deployment --port=80
	]"

class
	KUBECTL_QUICK

create
	make,
	make_with_namespace

feature {NONE} -- Initialization

	make (a_client: K8S_CLIENT)
			-- Create with client, using default namespace.
		require
			client_not_void: a_client /= Void
			client_configured: a_client.is_configured
		do
			client := a_client
			namespace := "default"
		ensure
			client_set: client = a_client
			default_namespace: namespace.same_string ("default")
		end

	make_with_namespace (a_client: K8S_CLIENT; a_namespace: STRING)
			-- Create with client and specific namespace.
		require
			client_not_void: a_client /= Void
			client_configured: a_client.is_configured
			namespace_not_empty: not a_namespace.is_empty
		do
			client := a_client
			namespace := a_namespace
		ensure
			client_set: client = a_client
			namespace_set: namespace.same_string (a_namespace)
		end

feature -- Access

	client: K8S_CLIENT
			-- Underlying K8s client.

	namespace: STRING assign set_namespace
			-- Current working namespace.

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := client.has_error
		end

	error_message: STRING
			-- Error from last operation.
		do
			Result := client.error_message
		end

feature -- Namespace Control

	set_namespace (a_namespace: STRING)
			-- Change working namespace (like kubectl config set-context --current --namespace=NS).
		require
			not_empty: not a_namespace.is_empty
		do
			namespace := a_namespace
		ensure
			namespace_set: namespace.same_string (a_namespace)
		end

	use_namespace (a_namespace: STRING): like Current
			-- Change namespace (fluent).
		require
			not_empty: not a_namespace.is_empty
		do
			namespace := a_namespace
			Result := Current
		ensure
			namespace_set: namespace.same_string (a_namespace)
		end

feature -- Quick Pod Commands

	run (a_name, a_image: STRING): detachable STRING
			-- Create pod quickly (like kubectl run NAME --image=IMAGE).
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
		local
			l_spec: POD_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_image (a_image).set_namespace (namespace)
			Result := client.create_pod (l_spec)
		end

	run_with_command (a_name, a_image: STRING; a_command: ARRAY [STRING]): detachable STRING
			-- Create pod with custom command.
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
		local
			l_spec: POD_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_image (a_image).set_namespace (namespace).set_command (a_command)
			Result := client.create_pod (l_spec)
		end

	logs (a_pod: STRING): detachable STRING
			-- Get pod logs (like kubectl logs POD).
		require
			pod_not_empty: not a_pod.is_empty
		do
			Result := client.pod_logs (a_pod, namespace)
		end

	delete_pod (a_name: STRING): BOOLEAN
			-- Delete pod (like kubectl delete pod NAME).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.delete_pod (a_name, namespace)
		end

	pods: detachable STRING
			-- List pods (like kubectl get pods).
		do
			Result := client.list_pods (namespace)
		end

	get_pod (a_name: STRING): detachable STRING
			-- Get pod details (like kubectl get pod NAME -o json).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_pod (a_name, namespace)
		end

feature -- Quick Deployment Commands

	create_deployment (a_name, a_image: STRING; a_replicas: INTEGER): detachable STRING
			-- Create deployment (like kubectl create deployment NAME --image=IMAGE --replicas=N).
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
			replicas_positive: a_replicas >= 0
		local
			l_spec: DEPLOYMENT_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_image (a_image).set_replicas (a_replicas).set_namespace (namespace)
			Result := client.create_deployment (l_spec)
		end

	scale (a_deployment: STRING; a_replicas: INTEGER): BOOLEAN
			-- Scale deployment (like kubectl scale deployment NAME --replicas=N).
		require
			name_not_empty: not a_deployment.is_empty
			replicas_non_negative: a_replicas >= 0
		do
			Result := client.scale_deployment (a_deployment, namespace, a_replicas)
		end

	restart (a_deployment: STRING): BOOLEAN
			-- Rollout restart (like kubectl rollout restart deployment NAME).
		require
			name_not_empty: not a_deployment.is_empty
		do
			Result := client.rollout_restart (a_deployment, namespace)
		end

	delete_deployment (a_name: STRING): BOOLEAN
			-- Delete deployment (like kubectl delete deployment NAME).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.delete_deployment (a_name, namespace)
		end

	deployments: detachable STRING
			-- List deployments (like kubectl get deployments).
		do
			Result := client.list_deployments (namespace)
		end

	get_deployment (a_name: STRING): detachable STRING
			-- Get deployment details (like kubectl get deployment NAME -o json).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_deployment (a_name, namespace)
		end

feature -- Quick Service Commands

	expose (a_name: STRING; a_port: INTEGER): detachable STRING
			-- Expose as ClusterIP service (like kubectl expose deployment NAME --port=PORT).
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
		local
			l_spec: SERVICE_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_namespace (namespace)
				.select_app (a_name)
				.add_simple_port (a_port)
				.set_cluster_ip_type
			Result := client.create_service (l_spec)
		end

	expose_lb (a_name: STRING; a_port: INTEGER): detachable STRING
			-- Expose as LoadBalancer (like kubectl expose deployment NAME --type=LoadBalancer --port=PORT).
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
		local
			l_spec: SERVICE_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_namespace (namespace)
				.select_app (a_name)
				.add_simple_port (a_port)
				.set_load_balancer_type
			Result := client.create_service (l_spec)
		end

	expose_node_port (a_name: STRING; a_port: INTEGER): detachable STRING
			-- Expose as NodePort (like kubectl expose deployment NAME --type=NodePort --port=PORT).
		require
			name_not_empty: not a_name.is_empty
			port_valid: a_port > 0 and a_port <= 65535
		local
			l_spec: SERVICE_SPEC
		do
			create l_spec.make
			l_spec := l_spec.set_name (a_name).set_namespace (namespace)
				.select_app (a_name)
				.add_simple_port (a_port)
				.set_node_port_type
			Result := client.create_service (l_spec)
		end

	delete_service (a_name: STRING): BOOLEAN
			-- Delete service (like kubectl delete service NAME).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.delete_service (a_name, namespace)
		end

	services: detachable STRING
			-- List services (like kubectl get services).
		do
			Result := client.list_services (namespace)
		end

	get_service (a_name: STRING): detachable STRING
			-- Get service details (like kubectl get service NAME -o json).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_service (a_name, namespace)
		end

feature -- Quick Namespace Commands

	namespaces: detachable STRING
			-- List namespaces (like kubectl get namespaces).
		do
			Result := client.list_namespaces
		end

	get_namespace (a_name: STRING): detachable STRING
			-- Get namespace details.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_namespace (a_name)
		end

feature -- Quick ConfigMap/Secret Commands

	configmaps: detachable STRING
			-- List configmaps (like kubectl get configmaps).
		do
			Result := client.list_configmaps (namespace)
		end

	get_configmap (a_name: STRING): detachable STRING
			-- Get configmap details.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_configmap (a_name, namespace)
		end

	secrets: detachable STRING
			-- List secrets (like kubectl get secrets).
		do
			Result := client.list_secrets (namespace)
		end

	get_secret (a_name: STRING): detachable STRING
			-- Get secret details.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := client.get_secret (a_name, namespace)
		end

feature -- Deploy and Expose (Compound Operations)

	deploy_and_expose (a_name, a_image: STRING; a_port, a_replicas: INTEGER): BOOLEAN
			-- Create deployment and expose as ClusterIP service in one operation.
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
			port_valid: a_port > 0 and a_port <= 65535
			replicas_positive: a_replicas >= 0
		local
			l_dep_spec: DEPLOYMENT_SPEC
			l_svc_spec: SERVICE_SPEC
		do
			-- Create deployment
			create l_dep_spec.make
			l_dep_spec := l_dep_spec.set_name (a_name).set_image (a_image)
				.set_replicas (a_replicas).set_namespace (namespace)
				.add_port ("http", a_port)
			if attached client.create_deployment (l_dep_spec) then
				-- Create service
				create l_svc_spec.make
				l_svc_spec := l_svc_spec.set_name (a_name).set_namespace (namespace)
					.select_app (a_name)
					.add_simple_port (a_port)
					.set_cluster_ip_type
				if attached client.create_service (l_svc_spec) then
					Result := True
				end
			end
		end

	deploy_and_expose_lb (a_name, a_image: STRING; a_port, a_replicas: INTEGER): BOOLEAN
			-- Create deployment and expose as LoadBalancer in one operation.
		require
			name_not_empty: not a_name.is_empty
			image_not_empty: not a_image.is_empty
			port_valid: a_port > 0 and a_port <= 65535
			replicas_positive: a_replicas >= 0
		local
			l_dep_spec: DEPLOYMENT_SPEC
			l_svc_spec: SERVICE_SPEC
		do
			-- Create deployment
			create l_dep_spec.make
			l_dep_spec := l_dep_spec.set_name (a_name).set_image (a_image)
				.set_replicas (a_replicas).set_namespace (namespace)
				.add_port ("http", a_port)
			if attached client.create_deployment (l_dep_spec) then
				-- Create LoadBalancer service
				create l_svc_spec.make
				l_svc_spec := l_svc_spec.set_name (a_name).set_namespace (namespace)
					.select_app (a_name)
					.add_simple_port (a_port)
					.set_load_balancer_type
				if attached client.create_service (l_svc_spec) then
					Result := True
				end
			end
		end

feature -- Delete Operations

	delete (a_resource_type, a_name: STRING): BOOLEAN
			-- Delete any resource type (like kubectl delete TYPE NAME).
		require
			type_not_empty: not a_resource_type.is_empty
			name_not_empty: not a_name.is_empty
		do
			if a_resource_type.same_string ("pod") then
				Result := client.delete_pod (a_name, namespace)
			elseif a_resource_type.same_string ("deployment") then
				Result := client.delete_deployment (a_name, namespace)
			elseif a_resource_type.same_string ("service") then
				Result := client.delete_service (a_name, namespace)
			end
		end

invariant
	client_not_void: client /= Void
	namespace_not_void: namespace /= Void
	namespace_not_empty: not namespace.is_empty

end
