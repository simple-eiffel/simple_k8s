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
			-- Test in-cluster detection (will be false on dev machine).
		note
			testing: "covers/{K8S_CONFIG}.is_in_cluster_environment"
		local
			cfg: K8S_CONFIG
		do
			create cfg.make
			-- On dev machine, we're not in cluster
			assert_false ("not_in_cluster", cfg.is_in_cluster_environment)
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
			api: FOUNDATION_API
		do
			create auth.make
			create cfg.make
			create api
			-- Should not crash
			auth.configure_http (api.http, cfg)
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

end
