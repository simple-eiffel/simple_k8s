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
			http: SIMPLE_HTTP
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

end
