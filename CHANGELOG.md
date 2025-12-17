# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
