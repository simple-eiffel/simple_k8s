# S04: FEATURE SPECIFICATIONS - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_K8S Features

### Initialization

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | () | Auto-detect config |
| make_from_file | (path: STRING) | From kubeconfig |
| make_in_cluster | () | In-cluster auth |

### Quick Operations (kubectl-like)

| Feature | Signature | Description |
|---------|-----------|-------------|
| run | (name, image: STRING) | Create pod |
| scale | (deployment: STRING; replicas: INTEGER) | Scale deployment |
| logs | (pod: STRING) | Get pod logs |
| pods | : detachable STRING | List pods |
| deployments | : detachable STRING | List deployments |
| services | : detachable STRING | List services |
| namespaces | : detachable STRING | List namespaces |

### Namespace Control

| Feature | Signature | Description |
|---------|-----------|-------------|
| use_namespace | (ns: STRING): like Current | Change namespace (fluent) |
| current_namespace | : STRING | Get current namespace |

## K8S_CLIENT Features

### Pod Operations

| Feature | Return Type | Description |
|---------|-------------|-------------|
| list_pods | detachable STRING | List pods (JSON) |
| get_pod | detachable STRING | Get single pod |
| create_pod | detachable STRING | Create from spec |
| delete_pod | BOOLEAN | Delete pod |
| pod_logs | detachable STRING | Get logs |

### Deployment Operations

| Feature | Return Type | Description |
|---------|-------------|-------------|
| list_deployments | detachable STRING | List deployments |
| get_deployment | detachable STRING | Get deployment |
| create_deployment | detachable STRING | Create from spec |
| delete_deployment | BOOLEAN | Delete deployment |
| scale_deployment | BOOLEAN | Scale replicas |
| rollout_restart | BOOLEAN | Trigger restart |

### Service Operations

| Feature | Return Type | Description |
|---------|-------------|-------------|
| list_services | detachable STRING | List services |
| get_service | detachable STRING | Get service |
| create_service | detachable STRING | Create from spec |
| delete_service | BOOLEAN | Delete service |

### Generic Operations

| Feature | Return Type | Description |
|---------|-------------|-------------|
| get_resource | detachable STRING | GET any path |
| post_resource | detachable STRING | POST any path |
| delete_resource | BOOLEAN | DELETE any path |
