note
	description: "Test runner for simple_k8s"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
		do
			create lib_tests
			run_tests
		end

feature -- Test Sets

	lib_tests: LIB_TESTS

feature -- Execution

	run_tests
		do
			io.put_string ("=== simple_k8s Tests ===%N%N")

			io.put_string ("K8S_ERROR Tests:%N")
			run_test (agent lib_tests.test_error_make, "test_error_make")
			run_test (agent lib_tests.test_error_from_status_401, "test_error_from_status_401")
			run_test (agent lib_tests.test_error_from_status_403, "test_error_from_status_403")
			run_test (agent lib_tests.test_error_from_status_404, "test_error_from_status_404")
			run_test (agent lib_tests.test_error_from_status_500, "test_error_from_status_500")
			run_test (agent lib_tests.test_error_to_string, "test_error_to_string")

			io.put_string ("%NK8S_CONFIG Tests:%N")
			run_test (agent lib_tests.test_config_make_empty, "test_config_make_empty")
			run_test (agent lib_tests.test_config_has_error_initially, "test_config_has_error_initially")
			run_test (agent lib_tests.test_config_is_in_cluster_environment, "test_config_is_in_cluster_environment")
			run_test (agent lib_tests.test_config_default_path, "test_config_default_path")

			io.put_string ("%NK8S_AUTH Tests:%N")
			run_test (agent lib_tests.test_auth_make, "test_auth_make")
			run_test (agent lib_tests.test_auth_set_token, "test_auth_set_token")
			run_test (agent lib_tests.test_auth_clear_token, "test_auth_clear_token")
			run_test (agent lib_tests.test_auth_configure_http, "test_auth_configure_http")

			io.put_string ("%NK8S_CLIENT Tests:%N")
			run_test (agent lib_tests.test_client_make_with_config, "test_client_make_with_config")
			run_test (agent lib_tests.test_client_is_configured, "test_client_is_configured")
			run_test (agent lib_tests.test_client_error_message_empty, "test_client_error_message_empty")

			io.put_string ("%NK8S_NAMESPACE Tests:%N")
			run_test (agent lib_tests.test_namespace_make, "test_namespace_make")
			run_test (agent lib_tests.test_namespace_from_json, "test_namespace_from_json")
			run_test (agent lib_tests.test_namespace_terminating, "test_namespace_terminating")
			run_test (agent lib_tests.test_namespace_labels_empty, "test_namespace_labels_empty")

			io.put_string ("%NK8S_CONFIGMAP Tests:%N")
			run_test (agent lib_tests.test_configmap_make, "test_configmap_make")
			run_test (agent lib_tests.test_configmap_from_json, "test_configmap_from_json")
			run_test (agent lib_tests.test_configmap_data_access, "test_configmap_data_access")
			run_test (agent lib_tests.test_configmap_keys, "test_configmap_keys")
			run_test (agent lib_tests.test_configmap_binary_data, "test_configmap_binary_data")

			io.put_string ("%NK8S_SECRET Tests:%N")
			run_test (agent lib_tests.test_secret_make, "test_secret_make")
			run_test (agent lib_tests.test_secret_from_json, "test_secret_from_json")
			run_test (agent lib_tests.test_secret_type_tls, "test_secret_type_tls")
			run_test (agent lib_tests.test_secret_type_docker_config, "test_secret_type_docker_config")
			run_test (agent lib_tests.test_secret_type_service_account, "test_secret_type_service_account")
			run_test (agent lib_tests.test_secret_keys, "test_secret_keys")
			run_test (agent lib_tests.test_secret_data_access, "test_secret_data_access")

			io.put_string ("%N=== Results: " + passed.out + " passed, " + failed.out + " failed ===%N")
			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

	run_test (a_test: PROCEDURE; a_name: STRING)
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_rescued := True
			retry
		end

	passed: INTEGER
	failed: INTEGER

end