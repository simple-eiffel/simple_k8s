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

			io.put_string ("%NK8S_POD Tests:%N")
			run_test (agent lib_tests.test_pod_make, "test_pod_make")
			run_test (agent lib_tests.test_pod_from_json, "test_pod_from_json")
			run_test (agent lib_tests.test_pod_status_pending, "test_pod_status_pending")
			run_test (agent lib_tests.test_pod_status_succeeded, "test_pod_status_succeeded")
			run_test (agent lib_tests.test_pod_status_failed, "test_pod_status_failed")
			run_test (agent lib_tests.test_pod_describe, "test_pod_describe")

			io.put_string ("%NK8S_DEPLOYMENT Tests:%N")
			run_test (agent lib_tests.test_deployment_make, "test_deployment_make")
			run_test (agent lib_tests.test_deployment_from_json, "test_deployment_from_json")
			run_test (agent lib_tests.test_deployment_progressing, "test_deployment_progressing")
			run_test (agent lib_tests.test_deployment_describe, "test_deployment_describe")

			io.put_string ("%NK8S_SERVICE Tests:%N")
			run_test (agent lib_tests.test_service_make, "test_service_make")
			run_test (agent lib_tests.test_service_from_json_clusterip, "test_service_from_json_clusterip")
			run_test (agent lib_tests.test_service_nodeport, "test_service_nodeport")
			run_test (agent lib_tests.test_service_loadbalancer, "test_service_loadbalancer")
			run_test (agent lib_tests.test_service_describe, "test_service_describe")

			io.put_string ("%NPOD_SPEC Tests:%N")
			run_test (agent lib_tests.test_pod_spec_make, "test_pod_spec_make")
			run_test (agent lib_tests.test_pod_spec_fluent_builder, "test_pod_spec_fluent_builder")
			run_test (agent lib_tests.test_pod_spec_env_and_ports, "test_pod_spec_env_and_ports")
			run_test (agent lib_tests.test_pod_spec_valid_k8s_name, "test_pod_spec_valid_k8s_name")
			run_test (agent lib_tests.test_pod_spec_to_json, "test_pod_spec_to_json")
			run_test (agent lib_tests.test_pod_spec_restart_policy, "test_pod_spec_restart_policy")

			io.put_string ("%NDEPLOYMENT_SPEC Tests:%N")
			run_test (agent lib_tests.test_deployment_spec_make, "test_deployment_spec_make")
			run_test (agent lib_tests.test_deployment_spec_fluent_builder, "test_deployment_spec_fluent_builder")
			run_test (agent lib_tests.test_deployment_spec_strategies, "test_deployment_spec_strategies")
			run_test (agent lib_tests.test_deployment_spec_zero_replicas, "test_deployment_spec_zero_replicas")
			run_test (agent lib_tests.test_deployment_spec_to_json, "test_deployment_spec_to_json")

			io.put_string ("%NSERVICE_SPEC Tests:%N")
			run_test (agent lib_tests.test_service_spec_make, "test_service_spec_make")
			run_test (agent lib_tests.test_service_spec_fluent_builder, "test_service_spec_fluent_builder")
			run_test (agent lib_tests.test_service_spec_types, "test_service_spec_types")
			run_test (agent lib_tests.test_service_spec_external_name, "test_service_spec_external_name")
			run_test (agent lib_tests.test_service_spec_to_json, "test_service_spec_to_json")

			io.put_string ("%NEdge Case Tests:%N")
			run_test (agent lib_tests.test_malformed_json_pod, "test_malformed_json_pod")
			run_test (agent lib_tests.test_malformed_json_deployment, "test_malformed_json_deployment")
			run_test (agent lib_tests.test_malformed_json_service, "test_malformed_json_service")
			run_test (agent lib_tests.test_empty_metadata, "test_empty_metadata")
			run_test (agent lib_tests.test_secret_base64_decoding, "test_secret_base64_decoding")

			io.put_string ("%NBoundary Condition Tests (Testing Hat):%N")
			run_test (agent lib_tests.test_error_status_409_conflict, "test_error_status_409_conflict")
			run_test (agent lib_tests.test_error_status_503_service_unavailable, "test_error_status_503_service_unavailable")
			run_test (agent lib_tests.test_service_port_boundary_min, "test_service_port_boundary_min")
			run_test (agent lib_tests.test_service_port_boundary_max, "test_service_port_boundary_max")
			run_test (agent lib_tests.test_config_from_nonexistent_file, "test_config_from_nonexistent_file")
			run_test (agent lib_tests.test_name_with_unicode_rejected, "test_name_with_unicode_rejected")
			run_test (agent lib_tests.test_service_port_nodeport_boundary, "test_service_port_nodeport_boundary")
			run_test (agent lib_tests.test_deployment_replicas_large_value, "test_deployment_replicas_large_value")
			run_test (agent lib_tests.test_pod_spec_empty_env_value, "test_pod_spec_empty_env_value")
			run_test (agent lib_tests.test_configmap_no_data, "test_configmap_no_data")
			run_test (agent lib_tests.test_service_headless, "test_service_headless")

			io.put_string ("%NMANIFEST_BUILDER Tests:%N")
			run_test (agent lib_tests.test_manifest_builder_make, "test_manifest_builder_make")
			run_test (agent lib_tests.test_manifest_builder_add_namespace, "test_manifest_builder_add_namespace")
			run_test (agent lib_tests.test_manifest_builder_add_deployment, "test_manifest_builder_add_deployment")
			run_test (agent lib_tests.test_manifest_builder_add_service, "test_manifest_builder_add_service")
			run_test (agent lib_tests.test_manifest_builder_add_service_lb, "test_manifest_builder_add_service_lb")
			run_test (agent lib_tests.test_manifest_builder_multi_document, "test_manifest_builder_multi_document")
			run_test (agent lib_tests.test_manifest_builder_configmap, "test_manifest_builder_configmap")
			run_test (agent lib_tests.test_manifest_builder_clear, "test_manifest_builder_clear")

			io.put_string ("%NK8S_CI_QUICK Tests:%N")
			run_test (agent lib_tests.test_ci_quick_make, "test_ci_quick_make")
			run_test (agent lib_tests.test_ci_quick_set_namespace, "test_ci_quick_set_namespace")

			io.put_string ("%NKUBECTL_QUICK Tests:%N")
			run_test (agent lib_tests.test_kubectl_quick_make, "test_kubectl_quick_make")
			run_test (agent lib_tests.test_kubectl_quick_namespace, "test_kubectl_quick_namespace")

			io.put_string ("%NSecurity Tests:%N")
			run_test (agent lib_tests.test_security_valid_k8s_names, "test_security_valid_k8s_names")
			run_test (agent lib_tests.test_security_invalid_k8s_names, "test_security_invalid_k8s_names")
			run_test (agent lib_tests.test_security_path_traversal_names, "test_security_path_traversal_names")
			run_test (agent lib_tests.test_security_json_escaping_env_vars, "test_security_json_escaping_env_vars")
			run_test (agent lib_tests.test_security_service_type_invariant, "test_security_service_type_invariant")
			run_test (agent lib_tests.test_security_deployment_strategy_invariant, "test_security_deployment_strategy_invariant")
			run_test (agent lib_tests.test_security_max_name_length, "test_security_max_name_length")
			run_test (agent lib_tests.test_security_is_valid_checks_all_constraints, "test_security_is_valid_checks_all_constraints")
			run_test (agent lib_tests.test_security_zero_replicas_valid, "test_security_zero_replicas_valid")

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
