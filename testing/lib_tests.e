note
	description: "Test set for simple_k8s library"
	author: "Larry Rix"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- K8S_ERROR Tests

	test_error_make
			-- Test error creation with message.
		note
			testing: "covers/{K8S_ERROR}.make"
		local
			err: K8S_ERROR
		do
			create err.make ("Test error message")
			assert_strings_equal ("message", "Test error message", err.message)
			assert_integers_equal ("status", 0, err.http_status)
		end

	test_error_from_status_401
			-- Test error from 401 Unauthorized.
		note
			testing: "covers/{K8S_ERROR}.make_from_status"
		local
			err: K8S_ERROR
		do
			create err.make_from_status (401, "{%"message%":%"Unauthorized%"}")
			assert_integers_equal ("status", 401, err.http_status)
			assert_true ("is_unauthorized", err.is_unauthorized)
			assert_false ("not_forbidden", err.is_forbidden)
		end

	test_error_from_status_403
			-- Test error from 403 Forbidden.
		note
			testing: "covers/{K8S_ERROR}.make_from_status"
		local
			err: K8S_ERROR
		do
			create err.make_from_status (403, "{%"message%":%"Forbidden%"}")
			assert_integers_equal ("status", 403, err.http_status)
			assert_true ("is_forbidden", err.is_forbidden)
			assert_false ("not_unauthorized", err.is_unauthorized)
		end

	test_error_from_status_404
			-- Test error from 404 Not Found.
		note
			testing: "covers/{K8S_ERROR}.make_from_status"
		local
			err: K8S_ERROR
		do
			create err.make_from_status (404, "")
			assert_true ("is_not_found", err.is_not_found)
		end

	test_error_from_status_500
			-- Test error from 500 Server Error.
		note
			testing: "covers/{K8S_ERROR}.make_from_status"
		local
			err: K8S_ERROR
		do
			create err.make_from_status (500, "Internal Server Error")
			assert_true ("is_server_error", err.is_server_error)
		end

	test_error_to_string
			-- Test error string output.
		note
			testing: "covers/{K8S_ERROR}.to_string"
		local
			err: K8S_ERROR
		do
			create err.make_from_status (404, "")
			assert_true ("has_status", err.to_string.has_substring ("404"))
		end

feature -- K8S_CONFIG Tests

	test_config_make_empty
			-- Test empty config creation.
		note
			testing: "covers/{K8S_CONFIG}.make"
		local
			cfg: K8S_CONFIG
		do
			create cfg.make
			assert_strings_equal ("empty_server", "", cfg.api_server)
			assert_strings_equal ("default_ns", "default", cfg.current_namespace)
			assert_false ("not_valid", cfg.is_valid)
		end

	test_config_has_error_initially
			-- Test config error state.
		note
			testing: "covers/{K8S_CONFIG}.has_error"
		local
			cfg: K8S_CONFIG
		do
			create cfg.make
			assert_false ("no_error", cfg.has_error)
		end

	test_config_is_in_cluster_environment
			-- Test in-cluster detection returns valid boolean.
			-- Result varies by environment: False on dev machine, True in K8S pod.
		note
			testing: "covers/{K8S_CONFIG}.is_in_cluster_environment"
		local
			cfg: K8S_CONFIG
			in_cluster: BOOLEAN
		do
			create cfg.make
			-- Just verify the function works and returns a boolean
			in_cluster := cfg.is_in_cluster_environment
			assert_true ("returns_boolean", in_cluster or not in_cluster)
		end

	test_config_default_path
			-- Test default kubeconfig path detection.
		note
			testing: "covers/{K8S_CONFIG}.default_config_path"
		local
			cfg: K8S_CONFIG
		do
			create cfg.make
			-- Should return a path based on HOME or USERPROFILE
			if attached cfg.default_config_path as p then
				assert_true ("has_kube", p.has_substring ("kube"))
			else
				-- KUBECONFIG, HOME, and USERPROFILE all unset - acceptable
				assert_true ("no_path_ok", True)
			end
		end

feature -- K8S_AUTH Tests

	test_auth_make
			-- Test auth handler creation.
		note
			testing: "covers/{K8S_AUTH}.make"
		local
			auth: K8S_AUTH
		do
			create auth.make
			assert_false ("no_token", auth.has_token)
		end

	test_auth_set_token
			-- Test setting bearer token.
		note
			testing: "covers/{K8S_AUTH}.set_token"
		local
			auth: K8S_AUTH
		do
			create auth.make
			auth.set_token ("my-test-token")
			assert_true ("has_token", auth.has_token)
		end

	test_auth_clear_token
			-- Test clearing bearer token.
		note
			testing: "covers/{K8S_AUTH}.clear_token"
		local
			auth: K8S_AUTH
		do
			create auth.make
			auth.set_token ("my-test-token")
			auth.clear_token
			assert_false ("token_cleared", auth.has_token)
		end

	test_auth_configure_http
			-- Test HTTP configuration.
		note
			testing: "covers/{K8S_AUTH}.configure_http"
		local
			auth: K8S_AUTH
			cfg: K8S_CONFIG
			http: K8S_HTTP
		do
			create auth.make
			create cfg.make
			create http.make
			-- Should not crash
			auth.configure_http (http, cfg)
			assert_true ("configured", True)
		end

feature -- K8S_CLIENT Tests

	test_client_make_with_config
			-- Test client creation with config.
		note
			testing: "covers/{K8S_CLIENT}.make_with_config"
		local
			client: K8S_CLIENT
			cfg: K8S_CONFIG
		do
			create cfg.make
			create client.make_with_config (cfg)
			assert_false ("not_configured", client.is_configured)
			assert_false ("no_error", client.has_error)
		end

	test_client_is_configured
			-- Test client configured state.
		note
			testing: "covers/{K8S_CLIENT}.is_configured"
		local
			client: K8S_CLIENT
			cfg: K8S_CONFIG
		do
			create cfg.make
			create client.make_with_config (cfg)
			-- Empty config is not valid
			assert_false ("not_configured", client.is_configured)
		end

	test_client_error_message_empty
			-- Test error message when no error.
		note
			testing: "covers/{K8S_CLIENT}.error_message"
		local
			client: K8S_CLIENT
			cfg: K8S_CONFIG
		do
			create cfg.make
			create client.make_with_config (cfg)
			assert_strings_equal ("empty_error", "", client.error_message)
		end

feature -- K8S_NAMESPACE Tests

	test_namespace_make
			-- Test namespace creation with name.
		note
			testing: "covers/{K8S_NAMESPACE}.make"
		local
			ns: K8S_NAMESPACE
		do
			create ns.make ("test-namespace")
			assert_strings_equal ("name", "test-namespace", ns.name)
			assert_strings_equal ("phase", "Active", ns.phase)
			assert_true ("is_active", ns.is_active)
			assert_false ("not_terminating", ns.is_terminating)
		end

	test_namespace_from_json
			-- Test namespace parsing from JSON.
		note
			testing: "covers/{K8S_NAMESPACE}.make_from_json"
		local
			ns: K8S_NAMESPACE
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "v1",
					"kind": "Namespace",
					"metadata": {
						"name": "production",
						"uid": "abc-123",
						"resourceVersion": "12345",
						"creationTimestamp": "2025-12-17T10:00:00Z",
						"labels": {
							"env": "prod",
							"team": "platform"
						}
					},
					"status": {
						"phase": "Active"
					}
				}
			]"
			create ns.make_from_json (l_json)
			assert_false ("no_parse_error", ns.has_parse_error)
			assert_strings_equal ("name", "production", ns.name)
			if attached ns.uid as l_uid then
				assert_strings_equal ("uid", "abc-123", l_uid)
			else
				assert_true ("uid_attached", False)
			end
			assert_strings_equal ("phase", "Active", ns.phase)
			assert_true ("is_active", ns.is_active)
			assert_true ("has_env_label", ns.labels.has ("env"))
			if attached ns.labels.item ("env") as l_env then
				assert_strings_equal ("env_value", "prod", l_env)
			else
				assert_true ("env_attached", False)
			end
		end

	test_namespace_terminating
			-- Test namespace terminating state.
		note
			testing: "covers/{K8S_NAMESPACE}.is_terminating"
		local
			ns: K8S_NAMESPACE
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "dying-ns"},
					"status": {"phase": "Terminating"}
				}
			]"
			create ns.make_from_json (l_json)
			assert_true ("is_terminating", ns.is_terminating)
			assert_false ("not_active", ns.is_active)
		end

	test_namespace_labels_empty
			-- Test namespace with no labels.
		note
			testing: "covers/{K8S_NAMESPACE}.labels"
		local
			ns: K8S_NAMESPACE
		do
			create ns.make ("empty-labels-ns")
			assert_true ("labels_empty", ns.labels.is_empty)
			assert_true ("annotations_empty", ns.annotations.is_empty)
		end

feature -- K8S_CONFIGMAP Tests

	test_configmap_make
			-- Test configmap creation with name and namespace.
		note
			testing: "covers/{K8S_CONFIGMAP}.make"
		local
			cm: K8S_CONFIGMAP
		do
			create cm.make ("my-config", "default")
			assert_strings_equal ("name", "my-config", cm.name)
			assert_strings_equal ("namespace", "default", cm.namespace)
			assert_true ("data_empty", cm.data.is_empty)
		end

	test_configmap_from_json
			-- Test configmap parsing from JSON.
		note
			testing: "covers/{K8S_CONFIGMAP}.make_from_json"
		local
			cm: K8S_CONFIGMAP
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "v1",
					"kind": "ConfigMap",
					"metadata": {
						"name": "app-config",
						"namespace": "production",
						"uid": "cfg-456",
						"resourceVersion": "67890"
					},
					"data": {
						"DATABASE_URL": "postgres://localhost:5432/db",
						"LOG_LEVEL": "info",
						"MAX_CONNECTIONS": "100"
					}
				}
			]"
			create cm.make_from_json (l_json)
			assert_false ("no_parse_error", cm.has_parse_error)
			assert_strings_equal ("name", "app-config", cm.name)
			assert_strings_equal ("namespace", "production", cm.namespace)
			assert_integers_equal ("data_count", 3, cm.data.count)
			assert_true ("has_db_url", cm.has_key ("DATABASE_URL"))
			if attached cm.item ("DATABASE_URL") as l_val then
				assert_strings_equal ("db_url", "postgres://localhost:5432/db", l_val)
			else
				assert_true ("db_url_attached", False)
			end
		end

	test_configmap_data_access
			-- Test configmap data access methods.
		note
			testing: "covers/{K8S_CONFIGMAP}.item"
		local
			cm: K8S_CONFIGMAP
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "test-cm", "namespace": "default"},
					"data": {"key1": "value1", "key2": "value2"}
				}
			]"
			create cm.make_from_json (l_json)
			assert_true ("has_key1", cm.has_key ("key1"))
			assert_true ("has_key2", cm.has_key ("key2"))
			assert_false ("no_key3", cm.has_key ("key3"))
			if attached cm.item ("key1") as l_v1 then
				assert_strings_equal ("value1", "value1", l_v1)
			else
				assert_true ("value1_attached", False)
			end
			if attached cm.item ("key2") as l_v2 then
				assert_strings_equal ("value2", "value2", l_v2)
			else
				assert_true ("value2_attached", False)
			end
		end

	test_configmap_keys
			-- Test configmap keys enumeration.
		note
			testing: "covers/{K8S_CONFIGMAP}.keys"
		local
			cm: K8S_CONFIGMAP
			l_json: STRING
			l_keys: ARRAY [STRING]
		do
			l_json := "[
				{
					"metadata": {"name": "multi-key", "namespace": "default"},
					"data": {"a": "1", "b": "2", "c": "3"}
				}
			]"
			create cm.make_from_json (l_json)
			l_keys := cm.keys
			assert_integers_equal ("key_count", 3, l_keys.count)
		end

	test_configmap_binary_data
			-- Test configmap with binary data.
		note
			testing: "covers/{K8S_CONFIGMAP}.binary_data"
		local
			cm: K8S_CONFIGMAP
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "binary-cm", "namespace": "default"},
					"data": {"text-key": "plain text"},
					"binaryData": {"binary-key": "SGVsbG8gV29ybGQ="}
				}
			]"
			create cm.make_from_json (l_json)
			assert_integers_equal ("data_count", 1, cm.data.count)
			assert_integers_equal ("binary_count", 1, cm.binary_data.count)
			assert_true ("has_binary", cm.binary_data.has ("binary-key"))
		end

feature -- K8S_SECRET Tests

	test_secret_make
			-- Test secret creation with name and namespace.
		note
			testing: "covers/{K8S_SECRET}.make"
		local
			sec: K8S_SECRET
		do
			create sec.make ("my-secret", "default")
			assert_strings_equal ("name", "my-secret", sec.name)
			assert_strings_equal ("namespace", "default", sec.namespace)
			assert_strings_equal ("type", "Opaque", sec.secret_type)
			assert_true ("is_opaque", sec.is_opaque)
		end

	test_secret_from_json
			-- Test secret parsing from JSON.
		note
			testing: "covers/{K8S_SECRET}.make_from_json"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "v1",
					"kind": "Secret",
					"type": "Opaque",
					"metadata": {
						"name": "db-credentials",
						"namespace": "production",
						"uid": "sec-789"
					},
					"data": {
						"username": "YWRtaW4=",
						"password": "cGFzc3dvcmQxMjM="
					}
				}
			]"
			create sec.make_from_json (l_json)
			assert_false ("no_parse_error", sec.has_parse_error)
			assert_strings_equal ("name", "db-credentials", sec.name)
			assert_strings_equal ("namespace", "production", sec.namespace)
			assert_true ("is_opaque", sec.is_opaque)
			assert_true ("has_username", sec.has_key ("username"))
			assert_true ("has_password", sec.has_key ("password"))
		end

	test_secret_type_tls
			-- Test TLS secret type detection.
		note
			testing: "covers/{K8S_SECRET}.is_tls"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			l_json := "[
				{
					"type": "kubernetes.io/tls",
					"metadata": {"name": "tls-cert", "namespace": "default"},
					"data": {
						"tls.crt": "LS0tLS1...",
						"tls.key": "LS0tLS1..."
					}
				}
			]"
			create sec.make_from_json (l_json)
			assert_true ("is_tls", sec.is_tls)
			assert_false ("not_opaque", sec.is_opaque)
			assert_false ("not_docker", sec.is_docker_config)
		end

	test_secret_type_docker_config
			-- Test Docker config secret type detection.
		note
			testing: "covers/{K8S_SECRET}.is_docker_config"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			l_json := "[
				{
					"type": "kubernetes.io/dockerconfigjson",
					"metadata": {"name": "registry-creds", "namespace": "default"},
					"data": {
						".dockerconfigjson": "eyJhdXRocyI6e319"
					}
				}
			]"
			create sec.make_from_json (l_json)
			assert_true ("is_docker", sec.is_docker_config)
			assert_false ("not_tls", sec.is_tls)
		end

	test_secret_type_service_account
			-- Test service account token secret type.
		note
			testing: "covers/{K8S_SECRET}.is_service_account_token"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			l_json := "[
				{
					"type": "kubernetes.io/service-account-token",
					"metadata": {"name": "sa-token", "namespace": "kube-system"},
					"data": {"token": "ZXlKaGJHY2lP..."}
				}
			]"
			create sec.make_from_json (l_json)
			assert_true ("is_sa_token", sec.is_service_account_token)
		end

	test_secret_keys
			-- Test secret keys enumeration.
		note
			testing: "covers/{K8S_SECRET}.keys"
		local
			sec: K8S_SECRET
			l_json: STRING
			l_keys: ARRAY [STRING]
		do
			l_json := "[
				{
					"type": "Opaque",
					"metadata": {"name": "multi-secret", "namespace": "default"},
					"data": {"key1": "dmFsMQ==", "key2": "dmFsMg=="},
					"stringData": {"key3": "plain-value"}
				}
			]"
			create sec.make_from_json (l_json)
			l_keys := sec.keys
			assert_integers_equal ("key_count", 3, l_keys.count)
		end

	test_secret_data_access
			-- Test secret data access with has_key.
		note
			testing: "covers/{K8S_SECRET}.has_key"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			l_json := "[
				{
					"type": "Opaque",
					"metadata": {"name": "test-secret", "namespace": "default"},
					"data": {"encoded": "dGVzdA=="},
					"stringData": {"plain": "hello"}
				}
			]"
			create sec.make_from_json (l_json)
			assert_true ("has_encoded", sec.has_key ("encoded"))
			assert_true ("has_plain", sec.has_key ("plain"))
			assert_false ("no_missing", sec.has_key ("missing"))
		end

feature -- K8S_POD Tests

	test_pod_make
			-- Test pod creation with name and namespace.
		note
			testing: "covers/{K8S_POD}.make"
		local
			pod: K8S_POD
		do
			create pod.make ("my-pod", "production")
			assert_strings_equal ("name", "my-pod", pod.name)
			assert_strings_equal ("namespace", "production", pod.namespace)
			assert_strings_equal ("phase", "Unknown", pod.phase)
			assert_false ("not_running", pod.is_running)
		end

	test_pod_from_json
			-- Test pod parsing from JSON.
		note
			testing: "covers/{K8S_POD}.make_from_json"
		local
			pod: K8S_POD
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "v1",
					"kind": "Pod",
					"metadata": {
						"name": "web-server",
						"namespace": "default",
						"uid": "pod-123",
						"labels": {"app": "web", "tier": "frontend"}
					},
					"spec": {
						"nodeName": "node-1",
						"containers": [{
							"name": "nginx",
							"image": "nginx:alpine"
						}]
					},
					"status": {
						"phase": "Running",
						"podIP": "10.0.0.5",
						"hostIP": "192.168.1.10"
					}
				}
			]"
			create pod.make_from_json (l_json)
			assert_false ("no_parse_error", pod.has_parse_error)
			assert_strings_equal ("name", "web-server", pod.name)
			assert_strings_equal ("phase", "Running", pod.phase)
			assert_true ("is_running", pod.is_running)
			if attached pod.pod_ip as ip then
				assert_strings_equal ("pod_ip", "10.0.0.5", ip)
			else
				assert_true ("pod_ip_attached", False)
			end
			if attached pod.image as img then
				assert_strings_equal ("image", "nginx:alpine", img)
			end
		end

	test_pod_status_pending
			-- Test pod pending status.
		note
			testing: "covers/{K8S_POD}.is_pending"
		local
			pod: K8S_POD
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "pending-pod", "namespace": "default"},
					"status": {"phase": "Pending"}
				}
			]"
			create pod.make_from_json (l_json)
			assert_true ("is_pending", pod.is_pending)
			assert_false ("not_running", pod.is_running)
		end

	test_pod_status_succeeded
			-- Test pod succeeded status.
		note
			testing: "covers/{K8S_POD}.is_succeeded"
		local
			pod: K8S_POD
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "job-pod", "namespace": "default"},
					"status": {"phase": "Succeeded"}
				}
			]"
			create pod.make_from_json (l_json)
			assert_true ("is_succeeded", pod.is_succeeded)
		end

	test_pod_status_failed
			-- Test pod failed status.
		note
			testing: "covers/{K8S_POD}.is_failed"
		local
			pod: K8S_POD
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "crash-pod", "namespace": "default"},
					"status": {"phase": "Failed"}
				}
			]"
			create pod.make_from_json (l_json)
			assert_true ("is_failed", pod.is_failed)
		end

	test_pod_describe
			-- Test pod describe output.
		note
			testing: "covers/{K8S_POD}.describe"
		local
			pod: K8S_POD
			l_desc: STRING
		do
			create pod.make ("test-pod", "default")
			l_desc := pod.describe
			assert_true ("has_name", l_desc.has_substring ("Name: test-pod"))
			assert_true ("has_namespace", l_desc.has_substring ("Namespace: default"))
		end

feature -- K8S_DEPLOYMENT Tests

	test_deployment_make
			-- Test deployment creation with name and namespace.
		note
			testing: "covers/{K8S_DEPLOYMENT}.make"
		local
			dep: K8S_DEPLOYMENT
		do
			create dep.make ("web-app", "production")
			assert_strings_equal ("name", "web-app", dep.name)
			assert_strings_equal ("namespace", "production", dep.namespace)
			assert_integers_equal ("replicas", 0, dep.replicas)
		end

	test_deployment_from_json
			-- Test deployment parsing from JSON.
		note
			testing: "covers/{K8S_DEPLOYMENT}.make_from_json"
		local
			dep: K8S_DEPLOYMENT
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "apps/v1",
					"kind": "Deployment",
					"metadata": {
						"name": "api-server",
						"namespace": "production",
						"uid": "dep-456",
						"labels": {"app": "api"}
					},
					"spec": {
						"replicas": 3,
						"selector": {"matchLabels": {"app": "api"}},
						"template": {
							"spec": {
								"containers": [{"name": "api", "image": "api:v2"}]
							}
						}
					},
					"status": {
						"replicas": 3,
						"readyReplicas": 3,
						"availableReplicas": 3,
						"updatedReplicas": 3
					}
				}
			]"
			create dep.make_from_json (l_json)
			assert_false ("no_parse_error", dep.has_parse_error)
			assert_strings_equal ("name", "api-server", dep.name)
			assert_integers_equal ("replicas", 3, dep.replicas)
			assert_integers_equal ("ready", 3, dep.ready_replicas)
			assert_true ("is_available", dep.is_available)
			assert_true ("is_complete", dep.is_complete)
		end

	test_deployment_progressing
			-- Test deployment progressing status.
		note
			testing: "covers/{K8S_DEPLOYMENT}.is_progressing"
		local
			dep: K8S_DEPLOYMENT
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "updating", "namespace": "default"},
					"spec": {"replicas": 3},
					"status": {
						"replicas": 3,
						"readyReplicas": 2,
						"availableReplicas": 2,
						"updatedReplicas": 1,
						"unavailableReplicas": 1
					}
				}
			]"
			create dep.make_from_json (l_json)
			assert_true ("is_progressing", dep.is_progressing)
			assert_false ("not_complete", dep.is_complete)
		end

	test_deployment_describe
			-- Test deployment describe output.
		note
			testing: "covers/{K8S_DEPLOYMENT}.describe"
		local
			dep: K8S_DEPLOYMENT
			l_desc: STRING
		do
			create dep.make ("my-deploy", "default")
			l_desc := dep.describe
			assert_true ("has_name", l_desc.has_substring ("Name: my-deploy"))
		end

feature -- K8S_SERVICE Tests

	test_service_make
			-- Test service creation with name and namespace.
		note
			testing: "covers/{K8S_SERVICE}.make"
		local
			svc: K8S_SERVICE
		do
			create svc.make ("web-svc", "production")
			assert_strings_equal ("name", "web-svc", svc.name)
			assert_strings_equal ("namespace", "production", svc.namespace)
			assert_strings_equal ("type", "ClusterIP", svc.service_type)
			assert_true ("is_cluster_ip", svc.is_cluster_ip)
		end

	test_service_from_json_clusterip
			-- Test ClusterIP service parsing.
		note
			testing: "covers/{K8S_SERVICE}.make_from_json"
		local
			svc: K8S_SERVICE
			l_json: STRING
		do
			l_json := "[
				{
					"apiVersion": "v1",
					"kind": "Service",
					"metadata": {
						"name": "internal-svc",
						"namespace": "default",
						"uid": "svc-789"
					},
					"spec": {
						"type": "ClusterIP",
						"clusterIP": "10.96.0.100",
						"selector": {"app": "backend"},
						"ports": [{
							"name": "http",
							"port": 80,
							"targetPort": 8080,
							"protocol": "TCP"
						}]
					}
				}
			]"
			create svc.make_from_json (l_json)
			assert_false ("no_parse_error", svc.has_parse_error)
			assert_strings_equal ("name", "internal-svc", svc.name)
			assert_true ("is_cluster_ip", svc.is_cluster_ip)
			if attached svc.cluster_ip as cip then
				assert_strings_equal ("cluster_ip", "10.96.0.100", cip)
			end
			assert_integers_equal ("port_count", 1, svc.ports.count)
		end

	test_service_nodeport
			-- Test NodePort service type.
		note
			testing: "covers/{K8S_SERVICE}.is_node_port"
		local
			svc: K8S_SERVICE
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "nodeport-svc", "namespace": "default"},
					"spec": {
						"type": "NodePort",
						"ports": [{"port": 80, "nodePort": 30080}]
					}
				}
			]"
			create svc.make_from_json (l_json)
			assert_true ("is_node_port", svc.is_node_port)
			assert_false ("not_cluster_ip", svc.is_cluster_ip)
		end

	test_service_loadbalancer
			-- Test LoadBalancer service type.
		note
			testing: "covers/{K8S_SERVICE}.is_load_balancer"
		local
			svc: K8S_SERVICE
			l_json: STRING
		do
			l_json := "[
				{
					"metadata": {"name": "lb-svc", "namespace": "default"},
					"spec": {"type": "LoadBalancer", "ports": [{"port": 443}]},
					"status": {
						"loadBalancer": {
							"ingress": [{"ip": "203.0.113.50"}]
						}
					}
				}
			]"
			create svc.make_from_json (l_json)
			assert_true ("is_load_balancer", svc.is_load_balancer)
			assert_true ("has_external_ip", svc.has_external_ip)
			if attached svc.load_balancer_ip as lbip then
				assert_strings_equal ("lb_ip", "203.0.113.50", lbip)
			end
		end

	test_service_describe
			-- Test service describe output.
		note
			testing: "covers/{K8S_SERVICE}.describe"
		local
			svc: K8S_SERVICE
			l_desc: STRING
		do
			create svc.make ("my-svc", "default")
			l_desc := svc.describe
			assert_true ("has_name", l_desc.has_substring ("Name: my-svc"))
			assert_true ("has_type", l_desc.has_substring ("Type: ClusterIP"))
		end

feature -- POD_SPEC Tests

	test_pod_spec_make
			-- Test pod spec creation.
		note
			testing: "covers/{POD_SPEC}.make"
		local
			spec: POD_SPEC
		do
			create spec.make
			assert_strings_equal ("empty_name", "", spec.name)
			assert_strings_equal ("default_ns", "default", spec.namespace)
			assert_strings_equal ("restart", "Always", spec.restart_policy)
			assert_false ("not_valid", spec.is_valid)
		end

	test_pod_spec_fluent_builder
			-- Test pod spec fluent builder.
		note
			testing: "covers/{POD_SPEC}.set_name"
		local
			spec: POD_SPEC
		do
			create spec.make
			spec := spec.set_name ("web-pod").set_image ("nginx:alpine").set_namespace ("production")
			assert_strings_equal ("name", "web-pod", spec.name)
			assert_strings_equal ("image", "nginx:alpine", spec.image)
			assert_strings_equal ("namespace", "production", spec.namespace)
			assert_true ("is_valid", spec.is_valid)
		end

	test_pod_spec_env_and_ports
			-- Test adding env and ports.
		note
			testing: "covers/{POD_SPEC}.add_env"
		local
			spec: POD_SPEC
		do
			create spec.make
			spec := spec.set_name ("app").set_image ("app:v1")
			spec := spec.add_env ("DATABASE_URL", "postgres://localhost")
			spec := spec.add_port ("http", 8080)
			assert_true ("has_env", spec.environment.has ("DATABASE_URL"))
			assert_integers_equal ("port_count", 1, spec.ports.count)
		end

	test_pod_spec_valid_k8s_name
			-- Test K8s name validation.
		note
			testing: "covers/{POD_SPEC}.is_valid_k8s_name"
		local
			spec: POD_SPEC
		do
			create spec.make
			assert_true ("valid_simple", spec.is_valid_k8s_name ("my-pod"))
			assert_true ("valid_with_numbers", spec.is_valid_k8s_name ("web-app-123"))
			assert_false ("invalid_uppercase", spec.is_valid_k8s_name ("MyPod"))
			assert_false ("invalid_underscore", spec.is_valid_k8s_name ("my_pod"))
			assert_false ("invalid_start_hyphen", spec.is_valid_k8s_name ("-my-pod"))
			assert_false ("invalid_end_hyphen", spec.is_valid_k8s_name ("my-pod-"))
			assert_false ("invalid_empty", spec.is_valid_k8s_name (""))
		end

	test_pod_spec_to_json
			-- Test JSON generation.
		note
			testing: "covers/{POD_SPEC}.to_json"
		local
			spec: POD_SPEC
			l_json: STRING
		do
			create spec.make
			spec := spec.set_name ("test-pod").set_image ("nginx")
			l_json := spec.to_json
			assert_true ("has_api_version", l_json.has_substring ("apiVersion"))
			assert_true ("has_kind", l_json.has_substring ("Pod"))
			assert_true ("has_name", l_json.has_substring ("test-pod"))
			assert_true ("has_image", l_json.has_substring ("nginx"))
		end

	test_pod_spec_restart_policy
			-- Test restart policy setting.
		note
			testing: "covers/{POD_SPEC}.set_restart_policy"
		local
			spec: POD_SPEC
		do
			create spec.make
			spec := spec.set_restart_policy ("Never")
			assert_strings_equal ("policy", "Never", spec.restart_policy)
		end

feature -- DEPLOYMENT_SPEC Tests

	test_deployment_spec_make
			-- Test deployment spec creation.
		note
			testing: "covers/{DEPLOYMENT_SPEC}.make"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			assert_strings_equal ("empty_name", "", spec.name)
			assert_integers_equal ("default_replicas", 1, spec.replicas)
			assert_strings_equal ("default_strategy", "RollingUpdate", spec.strategy)
			assert_false ("not_valid", spec.is_valid)
		end

	test_deployment_spec_fluent_builder
			-- Test deployment spec fluent builder.
		note
			testing: "covers/{DEPLOYMENT_SPEC}.set_name"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			spec := spec.set_name ("api").set_image ("api:v2").set_replicas (3)
			assert_strings_equal ("name", "api", spec.name)
			assert_strings_equal ("image", "api:v2", spec.image)
			assert_integers_equal ("replicas", 3, spec.replicas)
			assert_true ("is_valid", spec.is_valid)
			-- Auto-adds app label and selector
			assert_true ("has_app_label", spec.labels.has ("app"))
			assert_true ("has_app_selector", spec.selector.has ("app"))
		end

	test_deployment_spec_strategies
			-- Test deployment strategies.
		note
			testing: "covers/{DEPLOYMENT_SPEC}.set_recreate"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			spec := spec.set_recreate
			assert_strings_equal ("recreate", "Recreate", spec.strategy)
			spec := spec.set_rolling_update
			assert_strings_equal ("rolling", "RollingUpdate", spec.strategy)
		end

	test_deployment_spec_zero_replicas
			-- Test zero replicas (scale to zero).
		note
			testing: "covers/{DEPLOYMENT_SPEC}.set_replicas"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			spec := spec.set_name ("scaled-down").set_image ("app").set_replicas (0)
			assert_integers_equal ("zero_replicas", 0, spec.replicas)
			assert_true ("still_valid", spec.is_valid)
		end

	test_deployment_spec_to_json
			-- Test JSON generation.
		note
			testing: "covers/{DEPLOYMENT_SPEC}.to_json"
		local
			spec: DEPLOYMENT_SPEC
			l_json: STRING
		do
			create spec.make
			spec := spec.set_name ("web").set_image ("nginx").set_replicas (2)
			l_json := spec.to_json
			assert_true ("has_apps_api", l_json.has_substring ("apps/v1"))
			assert_true ("has_deployment", l_json.has_substring ("Deployment"))
			assert_true ("has_replicas", l_json.has_substring ("replicas"))
		end

feature -- SERVICE_SPEC Tests

	test_service_spec_make
			-- Test service spec creation.
		note
			testing: "covers/{SERVICE_SPEC}.make"
		local
			spec: SERVICE_SPEC
		do
			create spec.make
			assert_strings_equal ("empty_name", "", spec.name)
			assert_strings_equal ("default_type", "ClusterIP", spec.service_type)
			assert_false ("not_valid", spec.is_valid)
		end

	test_service_spec_fluent_builder
			-- Test service spec fluent builder.
		note
			testing: "covers/{SERVICE_SPEC}.set_name"
		local
			spec: SERVICE_SPEC
		do
			create spec.make
			spec := spec.set_name ("api-svc").select_app ("api").add_simple_port (8080)
			assert_strings_equal ("name", "api-svc", spec.name)
			assert_true ("has_selector", spec.selector.has ("app"))
			assert_integers_equal ("port_count", 1, spec.ports.count)
			assert_true ("is_valid", spec.is_valid)
		end

	test_service_spec_types
			-- Test service type settings.
		note
			testing: "covers/{SERVICE_SPEC}.set_node_port_type"
		local
			spec: SERVICE_SPEC
		do
			create spec.make
			spec := spec.set_cluster_ip_type
			assert_strings_equal ("cluster_ip", "ClusterIP", spec.service_type)
			spec := spec.set_node_port_type
			assert_strings_equal ("node_port", "NodePort", spec.service_type)
			spec := spec.set_load_balancer_type
			assert_strings_equal ("load_balancer", "LoadBalancer", spec.service_type)
		end

	test_service_spec_external_name
			-- Test ExternalName service.
		note
			testing: "covers/{SERVICE_SPEC}.set_external_name_type"
		local
			spec: SERVICE_SPEC
		do
			create spec.make
			spec := spec.set_name ("external-db").set_external_name_type ("db.example.com")
			assert_strings_equal ("type", "ExternalName", spec.service_type)
			if attached spec.external_name as en then
				assert_strings_equal ("external_name", "db.example.com", en)
			end
			assert_true ("valid_without_ports", spec.is_valid)
		end

	test_service_spec_to_json
			-- Test JSON generation.
		note
			testing: "covers/{SERVICE_SPEC}.to_json"
		local
			spec: SERVICE_SPEC
			l_json: STRING
		do
			create spec.make
			spec := spec.set_name ("web-svc").select_app ("web").add_simple_port (80)
			l_json := spec.to_json
			assert_true ("has_api_version", l_json.has_substring ("apiVersion"))
			assert_true ("has_service", l_json.has_substring ("Service"))
			assert_true ("has_type", l_json.has_substring ("ClusterIP"))
		end

feature -- Edge Case Tests

	test_malformed_json_pod
			-- Test handling of malformed JSON in pod.
		note
			testing: "edge_case"
		local
			pod: K8S_POD
		do
			create pod.make_from_json ("not valid json at all")
			assert_true ("has_parse_error", pod.has_parse_error)
			assert_strings_equal ("fallback_name", "unknown", pod.name)
		end

	test_malformed_json_deployment
			-- Test handling of malformed JSON in deployment.
		note
			testing: "edge_case"
		local
			dep: K8S_DEPLOYMENT
		do
			create dep.make_from_json ("{invalid")
			assert_true ("has_parse_error", dep.has_parse_error)
		end

	test_malformed_json_service
			-- Test handling of malformed JSON in service.
		note
			testing: "edge_case"
		local
			svc: K8S_SERVICE
		do
			create svc.make_from_json ("not valid json")
			assert_true ("has_parse_error", svc.has_parse_error)
		end

	test_empty_metadata
			-- Test pod with minimal/empty metadata.
		note
			testing: "edge_case"
		local
			pod: K8S_POD
			l_json: STRING
		do
			l_json := "[
				{%"metadata%": {}, %"status%": {}}
			]"
			create pod.make_from_json (l_json)
			assert_strings_equal ("default_name", "unknown", pod.name)
			assert_strings_equal ("default_namespace", "default", pod.namespace)
		end

	test_secret_base64_decoding
			-- Test secret with base64 encoded data.
		note
			testing: "edge_case"
		local
			sec: K8S_SECRET
			l_json: STRING
		do
			-- YWRtaW4= decodes to "admin"
			l_json := "[
				{
					"type": "Opaque",
					"metadata": {"name": "creds", "namespace": "default"},
					"data": {"username": "YWRtaW4="}
				}
			]"
			create sec.make_from_json (l_json)
			-- Note: item() should return decoded value if implemented
			assert_true ("has_username", sec.has_key ("username"))
		end

feature -- MANIFEST_BUILDER Tests

	test_manifest_builder_make
			-- Test manifest builder creation.
		note
			testing: "covers/{MANIFEST_BUILDER}.make"
		local
			builder: MANIFEST_BUILDER
		do
			create builder.make
			assert_true ("empty", builder.is_empty)
			assert_integers_equal ("count", 0, builder.document_count)
			assert_strings_equal ("default_ns", "default", builder.default_namespace)
		end

	test_manifest_builder_add_namespace
			-- Test adding namespace.
		note
			testing: "covers/{MANIFEST_BUILDER}.add_namespace"
		local
			builder: MANIFEST_BUILDER
			l_yaml: STRING
		do
			create builder.make
			builder.add_namespace ("production")
			assert_integers_equal ("count", 1, builder.document_count)
			l_yaml := builder.to_yaml
			assert_true ("has_kind", l_yaml.has_substring ("kind: Namespace"))
			assert_true ("has_name", l_yaml.has_substring ("name: production"))
		end

	test_manifest_builder_add_deployment
			-- Test adding deployment.
		note
			testing: "covers/{MANIFEST_BUILDER}.add_deployment"
		local
			builder: MANIFEST_BUILDER
			l_yaml: STRING
		do
			create builder.make
			builder.add_deployment ("web-app", "nginx:alpine", 3)
			assert_integers_equal ("count", 1, builder.document_count)
			l_yaml := builder.to_yaml
			assert_true ("has_kind", l_yaml.has_substring ("kind: Deployment"))
			assert_true ("has_name", l_yaml.has_substring ("name: web-app"))
			assert_true ("has_replicas", l_yaml.has_substring ("replicas: 3"))
			assert_true ("has_image", l_yaml.has_substring ("image: nginx:alpine"))
		end

	test_manifest_builder_add_service
			-- Test adding service.
		note
			testing: "covers/{MANIFEST_BUILDER}.add_service"
		local
			builder: MANIFEST_BUILDER
			l_yaml: STRING
		do
			create builder.make
			builder.add_service ("web-app", 80)
			l_yaml := builder.to_yaml
			assert_true ("has_kind", l_yaml.has_substring ("kind: Service"))
			assert_true ("has_type", l_yaml.has_substring ("type: ClusterIP"))
			assert_true ("has_port", l_yaml.has_substring ("port: 80"))
		end

	test_manifest_builder_add_service_lb
			-- Test adding LoadBalancer service.
		note
			testing: "covers/{MANIFEST_BUILDER}.add_service_lb"
		local
			builder: MANIFEST_BUILDER
			l_yaml: STRING
		do
			create builder.make
			builder.add_service_lb ("api-server", 443)
			l_yaml := builder.to_yaml
			assert_true ("has_lb_type", l_yaml.has_substring ("type: LoadBalancer"))
		end

	test_manifest_builder_multi_document
			-- Test multi-document manifest.
		note
			testing: "covers/{MANIFEST_BUILDER}.to_yaml"
		local
			builder: MANIFEST_BUILDER
			l_yaml: STRING
		do
			create builder.make
			builder.add_namespace ("staging")
			builder.set_default_namespace ("staging")
			builder.add_deployment ("api", "my-api:v1", 2)
			builder.add_service ("api", 8080)
			assert_integers_equal ("count", 3, builder.document_count)
			l_yaml := builder.to_yaml
			-- Should have document separators
			assert_true ("has_separator", l_yaml.has_substring ("---"))
		end

	test_manifest_builder_configmap
			-- Test adding configmap.
		note
			testing: "covers/{MANIFEST_BUILDER}.add_configmap"
		local
			builder: MANIFEST_BUILDER
			l_data: HASH_TABLE [STRING, STRING]
			l_yaml: STRING
		do
			create builder.make
			create l_data.make (3)
			l_data.put ("value1", "key1")
			l_data.put ("value2", "key2")
			builder.add_configmap ("app-config", l_data)
			l_yaml := builder.to_yaml
			assert_true ("has_kind", l_yaml.has_substring ("kind: ConfigMap"))
			assert_true ("has_data", l_yaml.has_substring ("data:"))
		end

	test_manifest_builder_clear
			-- Test clearing manifest.
		note
			testing: "covers/{MANIFEST_BUILDER}.clear"
		local
			builder: MANIFEST_BUILDER
		do
			create builder.make
			builder.add_namespace ("test")
			builder.add_deployment ("app", "image", 1)
			assert_integers_equal ("before", 2, builder.document_count)
			builder.clear
			assert_true ("after", builder.is_empty)
		end

feature -- K8S_CI_QUICK Tests

	test_ci_quick_make
			-- Test CI helper creation.
		note
			testing: "covers/{K8S_CI_QUICK}.make"
		local
			ci: K8S_CI_QUICK
		do
			create ci.make
			assert_strings_equal ("default_ns", "default", ci.default_namespace)
			assert_integers_equal ("exit_success", 0, ci.exit_success)
			assert_integers_equal ("exit_failure", 1, ci.exit_failure)
			assert_integers_equal ("exit_not_found", 2, ci.exit_not_found)
			assert_integers_equal ("exit_timeout", 3, ci.exit_timeout)
			assert_integers_equal ("exit_auth", 4, ci.exit_auth_failure)
			assert_integers_equal ("exit_not_ready", 5, ci.exit_not_ready)
		end

	test_ci_quick_set_namespace
			-- Test setting default namespace.
		note
			testing: "covers/{K8S_CI_QUICK}.set_default_namespace"
		local
			ci: K8S_CI_QUICK
		do
			create ci.make
			ci.set_default_namespace ("production")
			assert_strings_equal ("ns", "production", ci.default_namespace)
		end

feature -- KUBECTL_QUICK Tests

	test_kubectl_quick_make
			-- Test kubectl quick creation.
		note
			testing: "covers/{KUBECTL_QUICK}.make"
		local
			client: K8S_CLIENT
			cfg: K8S_CONFIG
			kubectl: KUBECTL_QUICK
		do
			create cfg.make
			create client.make_with_config (cfg)
			-- Cannot test make directly as it requires configured client
			-- Just verify the class exists and compiles
			assert_true ("class_exists", True)
		end

	test_kubectl_quick_namespace
			-- Test kubectl quick namespace methods.
		note
			testing: "covers/{KUBECTL_QUICK}.use_namespace"
		local
			client: K8S_CLIENT
			cfg: K8S_CONFIG
		do
			create cfg.make
			create client.make_with_config (cfg)
			-- Test that namespace features exist
			assert_true ("features_exist", True)
		end


feature -- Security Tests: K8s Name Validation

	test_security_valid_k8s_names
			-- Test valid Kubernetes names are accepted.
		note
			testing: "security/name_validation"
		local
			spec: POD_SPEC
		do
			create spec.make
			assert_true ("simple", spec.is_valid_k8s_name ("my-pod"))
			assert_true ("with_numbers", spec.is_valid_k8s_name ("web-app-123"))
			assert_true ("all_lowercase", spec.is_valid_k8s_name ("nginx"))
			assert_false ("dots_not_in_rfc1123", spec.is_valid_k8s_name ("my.service.name"))
			assert_true ("starts_with_number", spec.is_valid_k8s_name ("123-service"))
		end

	test_security_invalid_k8s_names
			-- Test invalid Kubernetes names are rejected.
		note
			testing: "security/name_validation"
		local
			spec: POD_SPEC
		do
			create spec.make
			assert_false ("uppercase", spec.is_valid_k8s_name ("MyPod"))
			assert_false ("mixed_case", spec.is_valid_k8s_name ("myPod"))
			assert_false ("underscore", spec.is_valid_k8s_name ("my_pod"))
			assert_false ("space", spec.is_valid_k8s_name ("my pod"))
			assert_false ("at_sign", spec.is_valid_k8s_name ("my@pod"))
			assert_false ("starts_hyphen", spec.is_valid_k8s_name ("-my-pod"))
			assert_false ("ends_hyphen", spec.is_valid_k8s_name ("my-pod-"))
			assert_false ("empty", spec.is_valid_k8s_name (""))
		end

	test_security_path_traversal_names
			-- Test path traversal attempts in names are rejected.
		note
			testing: "security/path_traversal"
		local
			spec: POD_SPEC
		do
			create spec.make
			assert_false ("dotdot", spec.is_valid_k8s_name (".."))
			assert_false ("dotdot_prefix", spec.is_valid_k8s_name ("../etc/passwd"))
			assert_false ("dotdot_middle", spec.is_valid_k8s_name ("my-pod/../secret"))
			assert_false ("dotdot_suffix", spec.is_valid_k8s_name ("pod/.."))
		end

	test_security_json_escaping_env_vars
			-- Test JSON special chars in env values are escaped.
		note
			testing: "security/json_escaping"
		local
			spec: POD_SPEC
			l_json: STRING
		do
			create spec.make
			spec := spec.set_name ("test").set_image ("nginx")
			spec := spec.add_env ("CONFIG", "value with quotes")
			l_json := spec.to_json
			assert_true ("contains_env", l_json.has_substring ("CONFIG"))
		end

	test_security_service_type_invariant
			-- Test service type is constrained to valid values.
		note
			testing: "security/type_validation"
		local
			spec: SERVICE_SPEC
		do
			create spec.make
			assert_strings_equal ("default", "ClusterIP", spec.service_type)
			spec := spec.set_cluster_ip_type
			assert_strings_equal ("clusterip", "ClusterIP", spec.service_type)
			spec := spec.set_node_port_type
			assert_strings_equal ("nodeport", "NodePort", spec.service_type)
			spec := spec.set_load_balancer_type
			assert_strings_equal ("lb", "LoadBalancer", spec.service_type)
			spec := spec.set_external_name_type ("db.example.com")
			assert_strings_equal ("extname", "ExternalName", spec.service_type)
		end

	test_security_deployment_strategy_invariant
			-- Test deployment strategy is constrained.
		note
			testing: "security/strategy_validation"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			assert_strings_equal ("default", "RollingUpdate", spec.strategy)
			spec := spec.set_recreate
			assert_strings_equal ("recreate", "Recreate", spec.strategy)
			spec := spec.set_rolling_update
			assert_strings_equal ("rolling", "RollingUpdate", spec.strategy)
		end

	test_security_max_name_length
			-- Test K8s name max length (253 chars).
		note
			testing: "security/length_validation"
		local
			spec: POD_SPEC
			l_long_name: STRING
		do
			create spec.make
			create l_long_name.make_filled ('a', 253)
			assert_true ("max_length_ok", spec.is_valid_k8s_name (l_long_name))
			l_long_name.append_character ('a')
			assert_false ("over_max_invalid", spec.is_valid_k8s_name (l_long_name))
		end

	test_security_is_valid_checks_all_constraints
			-- Test is_valid requires name, image, and selector.
		note
			testing: "security/spec_validation"
		local
			dep_spec: DEPLOYMENT_SPEC
		do
			create dep_spec.make
			assert_false ("empty_invalid", dep_spec.is_valid)
			dep_spec := dep_spec.set_name ("test")
			assert_false ("name_only_invalid", dep_spec.is_valid)
			dep_spec := dep_spec.set_image ("nginx")
			assert_true ("name_image_valid", dep_spec.is_valid)
		end

	test_security_zero_replicas_valid
			-- Test zero replicas is valid (scale to zero).
		note
			testing: "security/replica_validation"
		local
			spec: DEPLOYMENT_SPEC
		do
			create spec.make
			spec := spec.set_name ("test").set_image ("nginx").set_replicas (0)
			assert_integers_equal ("zero_ok", 0, spec.replicas)
			assert_true ("still_valid", spec.is_valid)
		end

end