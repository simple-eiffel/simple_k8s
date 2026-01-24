# S03: CONTRACTS - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## SIMPLE_K8S Contracts

### Initialization

```eiffel
make
    ensure
        client_created: client /= Void
        kubectl_created: kubectl /= Void

make_from_file (a_path: STRING)
    require
        path_not_empty: not a_path.is_empty
    ensure
        client_created: client /= Void

make_in_cluster
    ensure
        client_created: client /= Void
```

### Namespace Control

```eiffel
use_namespace (a_namespace: STRING): like Current
    require
        not_empty: not a_namespace.is_empty
    ensure
        namespace_changed: kubectl.namespace.same_string (a_namespace)
```

## K8S_CLIENT Contracts

### Pod Operations

```eiffel
list_pods (a_namespace: STRING): detachable STRING
    require
        namespace_not_empty: not a_namespace.is_empty
        configured: is_configured
    ensure
        success_means_result: not has_error implies Result /= Void
        failure_means_no_result: has_error implies Result = Void

create_pod (a_spec: POD_SPEC): detachable STRING
    require
        spec_valid: a_spec.is_valid
        configured: is_configured
    ensure
        success_means_result: not has_error implies Result /= Void
        failure_means_no_result: has_error implies Result = Void

delete_pod (a_name, a_namespace: STRING): BOOLEAN
    require
        name_not_empty: not a_name.is_empty
        namespace_not_empty: not a_namespace.is_empty
        configured: is_configured
    ensure
        success_consistency: Result = not has_error
```

### Scale Operations

```eiffel
scale_deployment (a_name, a_namespace: STRING; a_replicas: INTEGER): BOOLEAN
    require
        name_not_empty: not a_name.is_empty
        namespace_not_empty: not a_namespace.is_empty
        replicas_non_negative: a_replicas >= 0
        configured: is_configured
    ensure
        success_consistency: Result = not has_error
```

## Class Invariants

```eiffel
-- SIMPLE_K8S
invariant
    client_not_void: client /= Void
    kubectl_not_void: kubectl /= Void

-- K8S_CLIENT
invariant
    error_consistency: has_error = (last_error /= Void)
```
