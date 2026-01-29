<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.svg" alt="simple_ library logo" width="400">
</p>

# simple_k8s

**[Documentation](https://simple-eiffel.github.io/simple_k8s/)** | **[GitHub](https://github.com/simple-eiffel/simple_k8s)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()
[![Tests](https://img.shields.io/badge/tests-90%20passing-brightgreen.svg)]()

Kubernetes cluster orchestration library for Eiffel. Deploy, scale, and manage containerized workloads programmatically.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Development** - 90 tests passing (v0.5.0)

## Overview

SIMPLE_K8S provides programmatic access to Kubernetes clusters:

- **K8S_CLIENT** - Main facade for all Kubernetes API operations
- **Resource Classes** - K8S_POD, K8S_DEPLOYMENT, K8S_SERVICE, K8S_NAMESPACE, K8S_CONFIGMAP, K8S_SECRET
- **Spec Builders** - POD_SPEC, DEPLOYMENT_SPEC, SERVICE_SPEC for fluent resource configuration

### Basic Usage

```eiffel
local
    client: K8S_CLIENT
    spec: POD_SPEC
do
    create client.make  -- Auto-detects kubeconfig or in-cluster

    if client.is_configured then
        -- List pods in a namespace
        if attached client.list_pods ("default") as json then
            print (json)
        end

        -- Create a pod
        create spec.make ("my-pod", "default", "nginx:alpine")
        spec.add_port (80)
        if attached client.create_pod (spec) as result then
            print ("Pod created%N")
        end

        -- Scale a deployment
        client.scale_deployment ("my-app", "production", 3)
    end
end
```

## Features

- **Kubeconfig Parsing** - Automatic detection of ~/.kube/config or in-cluster credentials
- **Pod Operations** - List, get, create, delete pods; retrieve logs
- **Deployment Operations** - List, get, create, delete, scale deployments; rolling restart
- **Service Operations** - List, get, create, delete services
- **Namespace Operations** - List, get namespaces
- **ConfigMap Operations** - List, get configmaps with data access
- **Secret Operations** - List, get secrets with base64 decoding and type detection
- **Generic API** - get_resource, post_resource, delete_resource for any K8s API path
- **Design by Contract** - Full preconditions, postconditions, and invariants
- **SCOOP Compatible** - Concurrency-ready design

## Installation

1. Clone the repository:
```bash
git clone https://github.com/simple-eiffel/simple_k8s.git
```

2. Set environment variable (one-time setup for all simple_* libraries):
```bash
# Windows
set SIMPLE_EIFFEL=D:\prod

# MSYS2/Git Bash
export SIMPLE_EIFFEL=/d/prod
```

3. Add to your ECF:
```xml
<library name="simple_k8s" location="$SIMPLE_EIFFEL/simple_k8s/simple_k8s.ecf"/>
```

## Dependencies

- **simple_foundation_api** - HTTP client, JSON parsing, base64 encoding

## API Classes

| Class | Description |
|-------|-------------|
| `K8S_CLIENT` | Main facade for all Kubernetes API operations |
| `K8S_CONFIG` | Kubeconfig parsing and in-cluster detection |
| `K8S_AUTH` | Authentication (bearer token, client certs) |
| `K8S_ERROR` | Error classification and handling |
| `K8S_POD` | Pod resource representation |
| `K8S_DEPLOYMENT` | Deployment resource representation |
| `K8S_SERVICE` | Service resource representation |
| `K8S_NAMESPACE` | Namespace resource representation |
| `K8S_CONFIGMAP` | ConfigMap resource with data access |
| `K8S_SECRET` | Secret resource with base64 decoding |
| `POD_SPEC` | Fluent builder for pod configuration |
| `DEPLOYMENT_SPEC` | Fluent builder for deployment configuration |
| `SERVICE_SPEC` | Fluent builder for service configuration |
| `KUBECTL_QUICK` | One-liner convenience API for common operations |
| `MANIFEST_BUILDER` | YAML manifest generation for kubectl apply |
| `K8S_CI_QUICK` | CI/CD pipeline operations with exit codes |

## Building & Testing

### Compile Library

```bash
cd /d/prod/simple_k8s
/d/prod/ec.sh -batch -config simple_k8s.ecf -target simple_k8s -c_compile
```

### Compile Tests

```bash
/d/prod/ec.sh -batch -config simple_k8s.ecf -target simple_k8s_tests -c_compile
```

### Run Tests

```bash
./EIFGENs/simple_k8s_tests/W_code/simple_k8s.exe
```

**Test Results:** 90 tests passing

## Project Structure

```
simple_k8s/
├── src/
│   ├── core/
│   │   ├── k8s_client.e          # Main API facade
│   │   ├── k8s_config.e          # Kubeconfig parsing
│   │   ├── k8s_auth.e            # Authentication
│   │   └── k8s_error.e           # Error handling
│   ├── resources/
│   │   ├── k8s_pod.e             # Pod representation
│   │   ├── k8s_deployment.e      # Deployment representation
│   │   ├── k8s_service.e         # Service representation
│   │   ├── k8s_namespace.e       # Namespace representation
│   │   ├── k8s_configmap.e       # ConfigMap representation
│   │   └── k8s_secret.e          # Secret representation
│   ├── specs/
│   │   ├── pod_spec.e            # Pod builder
│   │   ├── deployment_spec.e     # Deployment builder
│   │   └── service_spec.e        # Service builder
│   └── util/
│       ├── kubectl_quick.e       # Convenience API
│       ├── manifest_builder.e    # YAML manifest generation
│       └── k8s_ci_quick.e        # CI/CD pipeline helper
├── testing/
│   ├── lib_tests.e               # Test cases (90 tests)
│   └── test_app.e                # Test runner
├── docs/                         # IUARC 5-doc standard
├── simple_k8s.ecf                # Library configuration
├── README.md                     # This file
└── CHANGELOG.md                  # Version history
```

## Roadmap

- [x] Core client with kubeconfig parsing (v0.1)
- [x] Pod, Deployment, Service operations (v0.2)
- [x] Namespace, ConfigMap, Secret resources (v0.3)
- [x] KUBECTL_QUICK - One-liner convenience API (v0.4)
- [x] K8S_CI_QUICK - CI pipeline operations with exit codes (v0.4)
- [x] MANIFEST_BUILDER - YAML manifest generation (v0.4)
- [ ] Watch/streaming operations
- [ ] Ingress and NetworkPolicy resources

## License

MIT License - see [LICENSE](LICENSE) file for details.

## See Also

- [Kubernetes API Documentation](https://kubernetes.io/docs/reference/kubernetes-api/)
- [simple_docker](https://github.com/simple-eiffel/simple_docker) - Docker container management
- [simple_foundation_api](https://github.com/simple-eiffel/simple_foundation_api) - HTTP and JSON utilities
