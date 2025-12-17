# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.5.0] - 2025-12-17

### Added
- **Security Tests** - Comprehensive security-focused test suite
  - K8s name validation tests (RFC 1123 label compliance)
  - Path traversal attack prevention tests
  - JSON escaping verification for environment variables
  - Service type invariant tests
  - Deployment strategy invariant tests
  - Maximum name length enforcement tests
  - Zero replicas validation tests
- 9 new security tests

### Changed
- Test count increased from 81 to 90 tests
- DBC contracts audited across all K8S classes

## [0.4.0] - 2025-12-17

### Added
- **KUBECTL_QUICK** - One-liner convenience API for common operations
  - `get_pods`, `get_deployments`, `get_services` with namespace parameter
  - `describe_pod`, `describe_deployment` returning formatted output
  - `scale`, `restart`, `delete_pod` operations
  - `logs` for pod log retrieval
  - `exec` command execution in pods
  - Default namespace configuration
- **MANIFEST_BUILDER** - YAML manifest generation for kubectl apply
  - Resource generators: `add_namespace`, `add_pod`, `add_deployment`, `add_service`
  - Service types: `add_service_lb`, `add_service_nodeport`, `add_service_full`
  - Config resources: `add_configmap`, `add_secret_opaque`
  - `add_raw` for custom YAML documents
  - Multi-document output with `to_yaml` (joined with ---)
  - `save_to_file` for direct file output
- **K8S_CI_QUICK** - CI/CD pipeline operations with exit codes
  - Exit codes: 0=success, 1=failure, 2=not_found, 3=timeout, 4=auth_failure, 5=not_ready
  - `wait_for_deployment_ready` with configurable timeout
  - `verify_deployment_replicas` for replica count verification
  - `scale_and_wait` for scaling with verification
  - `rollout_and_wait` for rolling restart with verification
  - `check_pod_running`, `check_namespace_active` health checks
  - `resource_exists` for existence verification
  - `is_cluster_reachable` for connectivity checks
  - `last_message`, `last_exit_code`, `print_result` for CI integration
- 12 new tests (8 MANIFEST_BUILDER, 2 K8S_CI_QUICK, 2 KUBECTL_QUICK)

### Changed
- Test count increased from 33 to 45 tests
- Fixed JSON iteration pattern in K8S_POD and K8S_DEPLOYMENT (object_item instead of object_at)

## [0.3.0] - 2025-12-17

### Added
- **K8S_NAMESPACE** - Namespace resource representation
  - Properties: name, uid, resource_version, phase, labels, annotations
  - Status queries: `is_active`, `is_terminating`
  - JSON parsing with `make_from_json`
- **K8S_CONFIGMAP** - ConfigMap resource representation
  - Properties: name, namespace, uid, data, binary_data, labels, annotations
  - Data access: `item`, `has_key`, `keys`
  - JSON parsing with `make_from_json`
- **K8S_SECRET** - Secret resource representation
  - Properties: name, namespace, uid, secret_type, data, string_data
  - Type queries: `is_opaque`, `is_tls`, `is_docker_config`, `is_service_account_token`
  - Data access: `item` (with base64 decoding), `has_key`, `keys`
  - JSON parsing with `make_from_json`
- K8S_CLIENT operations for new resources:
  - `list_namespaces`, `get_namespace`
  - `list_configmaps`, `get_configmap`
  - `list_secrets`, `get_secret`
- 16 new tests for resource classes (4 namespace, 5 configmap, 7 secret)

### Changed
- Test count increased from 17 to 33 tests
- Fixed JSON iteration pattern in resource classes (use explicit from/until loop)

## [0.2.0] - 2025-12-16

### Added
- **K8S_POD** - Pod resource representation
  - Properties: name, namespace, uid, phase, pod_ip, host_ip, node_name, image
  - Container statuses with restart counts
  - Status queries: `is_running`, `is_pending`, `is_succeeded`, `is_failed`, `is_ready`
  - `describe` output similar to kubectl
- **K8S_DEPLOYMENT** - Deployment resource representation
  - Properties: name, namespace, uid, replicas, ready_replicas, available_replicas
  - Status queries: `is_available`, `is_progressing`, `is_complete`
- **K8S_SERVICE** - Service resource representation
  - Properties: name, namespace, uid, service_type, cluster_ip, ports, selector
  - Type queries: `is_cluster_ip`, `is_node_port`, `is_load_balancer`
- **POD_SPEC** - Fluent builder for pod configuration
- **DEPLOYMENT_SPEC** - Fluent builder for deployment configuration
- **SERVICE_SPEC** - Fluent builder for service configuration
- K8S_CLIENT operations:
  - Pods: `list_pods`, `get_pod`, `create_pod`, `delete_pod`, `pod_logs`
  - Deployments: `list_deployments`, `get_deployment`, `create_deployment`, `delete_deployment`, `scale_deployment`, `rollout_restart`
  - Services: `list_services`, `get_service`, `create_service`, `delete_service`
  - Generic: `get_resource`, `post_resource`, `delete_resource`

### Changed
- K8S_CLIENT rewritten to use FOUNDATION_API
- K8S_AUTH updated to work with new client

## [0.1.0] - 2025-12-15

### Added
- Initial release of simple_k8s library
- **K8S_CLIENT** - Main facade for Kubernetes API operations
  - Automatic kubeconfig detection
  - In-cluster configuration support
- **K8S_CONFIG** - Kubeconfig parsing
  - Parses ~/.kube/config YAML
  - Extracts clusters, contexts, users
  - In-cluster detection via service account tokens
- **K8S_AUTH** - Authentication handling
  - Bearer token support
  - Client certificate support
  - HTTP header configuration
- **K8S_ERROR** - Error classification
  - HTTP status code mapping
  - Queries: `is_unauthorized`, `is_forbidden`, `is_not_found`, `is_server_error`
- Full Design by Contract with preconditions, postconditions, and invariants
- SCOOP-compatible design

### Dependencies
- simple_foundation_api
