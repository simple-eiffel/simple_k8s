# 7S-04: SIMPLE-STAR INTEGRATION - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Ecosystem Position

simple_k8s provides Kubernetes integration for Eiffel applications.

## Dependencies (Inbound)

| Library | Usage |
|---------|-------|
| simple_http | HTTP client for API |
| simple_json | JSON parsing |

## Dependents (Outbound)

| Library | How It Uses simple_k8s |
|---------|----------------------|
| simple_deploy | Deployment automation |
| (future) | CI/CD tools |

## Integration Patterns

### Basic Usage

```eiffel
local
    k8s: SIMPLE_K8S
do
    -- Auto-detects kubeconfig or in-cluster
    create k8s.make

    -- kubectl-like operations
    k8s.kubectl.run ("nginx", "nginx:alpine")
    k8s.kubectl.scale ("my-deployment", 3)

    -- List resources
    if attached k8s.pods as json then
        print (json)
    end
end
```

### With Specs

```eiffel
local
    pod: POD_SPEC
do
    create pod.make
    pod := pod.set_name ("my-pod")
              .set_image ("nginx:latest")
              .set_namespace ("default")

    if attached k8s.client.create_pod (pod) as result then
        print ("Pod created")
    end
end
```

## Ecosystem Conventions

1. **Naming**: SIMPLE_K8S facade, K8S_ prefix for internals
2. **Error handling**: has_error/last_error pattern
3. **JSON returns**: Raw JSON for flexibility
4. **Fluent specs**: Builder pattern for resources
