# Generic RAN CU+DU Intensive Workload

A comprehensive, scalable Radio Access Network (RAN) CU (Central Unit) + DU (Distributed Unit) workload simulation deployed with [kube-burner](https://github.com/kube-burner/kube-burner). This workload is designed to stress-test OpenShift/Kubernetes clusters in RAN edge computing environments.

## Overview

The CU+DU intensive workload simulates a realistic RAN environment by deploying multiple types of workloads across 5 namespaces (`workload-1` through `workload-5`). It combines various stress patterns including CPU-intensive tasks, network testing, storage I/O, and API server load to comprehensively test cluster performance and stability.

## Architecture

### Workload Distribution (workload-1)

The primary workload namespace (`workload-1`) contains the full comprehensive workload:

| Pod Type | Number of Pods | Container Specs | ConfigMaps/Secrets | Stress/Function |
|----------|----------------|-----------------|-------------------|-----------------|
| **Guaranteed** | 1 pod, 4 containers | **stress-ng**: 31 CPU, 1024M Memory, 16Gi HP<br>**nginx**: 1 CPU, 256Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- HTTP probes (startup/readiness/liveness) | 0 configmaps, 0 secrets, 1 service | 31 threads of 100% CPU stress, 512M virtual memory stress |
| **Storage I/O** | 2 pods, 4 containers each | **stress-ng**: 1 CPU, 1024M Memory, 3Gi HP<br>**nginx**: 1 CPU, 256Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- PVC mounts, hugepages | 0 configmaps, 0 secrets, 2 PVs/PVCs | Storage I/O stress with stress-ng hdd workers |
| **Stress pods** | 10 pods, 4 containers each | **stress-ng**: 50m CPU, 150Mi Memory<br>**3x extra**: 50m CPU, 150Mi Memory each<br>- Multiple volume mounts | 30 configmaps (10 regular + 20 immutable), 30 secrets | 2 CPU threads, 1 VM worker, 50M virtual memory stress |
| **kubectl apps** | 20 pods, 4 containers each | **kubectl**: 100m CPU, 128Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- RBAC permissions | 0 configmaps, 0 secrets, 20 serviceaccounts, 20 roles, 20 rolebindings | kubectl get pods/services every 5 seconds - API server stress |
| **Web servers** | 10 pods, 4 containers each | **stress-ng**: 50m CPU, 150Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- HTTP probes | 0 configmaps, 0 secrets, 10 services | Exposes port 8080 for HTTP probes |
| **Curl apps** | 10 pods, 4 containers each | **curl**: 100m CPU, 128Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- Liveness probes (15s interval) | 0 configmaps, 0 secrets | HTTP traffic generation, kubelet stress with probes |
| **iperf server** | 1 pod, 4 containers | **iperf3**: Default resources<br>**3x extra**: 50m CPU, 150Mi Memory each<br>- Custom networking, privileged security context | 1 serviceaccount, 1 SCC, machine config | Network throughput testing (server side) |
| **iperf client** | 1 pod, 4 containers | **iperf3**: Default resources<br>**3x extra**: 50m CPU, 150Mi Memory each<br>- Custom networking, privileged security context | Shared serviceaccount and SCC | Network throughput testing (client side) |

**workload-1 Totals**: 55 pods, 220 containers, 30 configmaps, 30 secrets, 4 PVs/PVCs, 11 services

### Workload Distribution (workload-2 through workload-5)

Each of the remaining namespaces (`workload-2`, `workload-3`, `workload-4`, `workload-5`) contains:

| Pod Type | Number of Pods | Container Specs | ConfigMaps/Secrets | Stress/Function |
|----------|----------------|-----------------|-------------------|-----------------|
| **Guaranteed** | 1 pod, 4 containers | **stress-ng**: 1m CPU, 512M Memory, 2Gi HP<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- HTTP probes | 0 configmaps, 0 secrets, 1 service | 1 CPU thread, 1 VM worker, 10M virtual memory stress |
| **Stress pods** | 1 pod, 4 containers | **stress-ng**: 50m CPU, 150Mi Memory<br>**3x extra**: 50m CPU, 150Mi Memory each<br>- Volume mounts | 30 configmaps (10 regular + 20 immutable), 30 secrets | 2 CPU threads, 1 VM worker, 50M virtual memory stress |
| **kubectl apps** | 1 pod, 4 containers | **kubectl**: 100m CPU, 128Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- RBAC permissions | 0 configmaps, 0 secrets, 1 serviceaccount, 1 role, 20 rolebindings | kubectl get pods/services every 5 seconds - API server stress |
| **Web servers** | 1 pod, 4 containers | **stress-ng**: 50m CPU, 150Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- HTTP probes | 0 configmaps, 0 secrets, 1 service | Exposes port 8080 for HTTP probes |
| **Curl apps** | 1 pod, 4 containers | **curl**: 100m CPU, 128Mi Memory<br>**nginx**: 100m CPU, 128Mi Memory<br>**2x extra**: 50m CPU, 150Mi Memory each<br>- Liveness probes (15s interval) | 0 configmaps, 0 secrets | HTTP traffic generation, kubelet stress with probes |

**Per namespace (2-5) Totals**: 5 pods, 20 containers, 30 configmaps, 30 secrets, 2 PVs/PVCs, 2 services

### Overall Totals

- **Total Pods**: 75 pods across 5 namespaces (55 in workload-1 + 5×4 in workload-2-5)
- **Total Containers**: 300 containers (220 in workload-1 + 20×4 in workload-2-5)
- **Total ConfigMaps**: 150 (30 + 30×4)
- **Total Secrets**: 150 (30 + 30×4)
- **Total PVs/PVCs**: 12 (4 + 2×4)
- **Total Services**: 19 (11 + 2×4)
- **Total ServiceAccounts**: 24 (20 + 1×4)
- **Total Roles**: 24 (20 + 1×4)
- **Total RoleBindings**: 100 (20 + 20×4)
- **Network Traffic**: HTTP probes + iperf throughput testing
- **API Load**: 20 kubectl operations every 5 seconds (workload-1) + 4 operations (workload-2-5)
- **Storage I/O**: Continuous HDD stress (workload-1 only)

### Workload Components

#### 1. Guaranteed Pods

- **Replicas**: 1 per namespace (5 total)
- **Resources**: CPU and memory with guaranteed QoS
- **Stress**: CPU and memory stress testing using stress-ng
- **Volumes**: ConfigMaps and Secrets mounted

#### 2. Storage I/O Pods (workload-1 only)

- **Replicas**: 2 pods
- **Purpose**: Storage performance testing
- **Resources**: 3Gi hugepages, persistent volumes
- **Stress**: Storage I/O operations

#### 3. Stress Pods

- **Replicas**: 10 in workload-1, 1 in others (14 total)
- **Purpose**: General CPU and memory stress
- **Image**: fedora-stress-ng
- **Volumes**: Multiple ConfigMaps and Secrets

#### 4. kubectl Apps

- **Replicas**: 20 in workload-1, 1 in others (24 total)
- **Purpose**: Kubernetes API server stress testing
- **Features**: ServiceAccounts, RBAC, kubectl operations
- **Stress**: Continuous kubectl get operations

#### 5. Web Server & Curl Apps

- **Web Servers**: 10 in workload-1, 1 in others (14 total)
- **Curl Clients**: 10 in workload-1, 1 in others (14 total)
- **Purpose**: HTTP traffic generation and probe stress
- **Features**: Liveness probes, network traffic simulation

#### 6. Network Testing (iperf)

- **Components**: 1 server + 1 client (workload-1 only)
- **Purpose**: Network performance and throughput testing
- **Features**: Custom networking, security contexts, machine config

## Requirements

### Kernel Modules

The following kernel modules are required for the iperf container to run:

- `nft_ct`
- `nft_log`

The workload includes a Machine Config which loads these modules. **Note**: This triggers a node reboot. If you already have these modules loaded and wish to skip the reboot, set the `SKIP_IPERF_MACHINE_CONFIG` environment variable.

## Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `REGISTRY` | Container registry for disconnected environments | `quay.io/rh_ee_apalanis/`, `quay.io/micosta/` | No |
| `IPERF_SERVER_IP` | IP address for iperf server | - | Yes (for iperf) |
| `IPERF_SUBNET` | Subnet for iperf networking | - | Yes (for iperf) |
| `IPERF_SERVER_NETWORK_DEFS` | Network definitions for iperf server | - | Yes (for iperf) |
| `IPERF_CLIENT_NETWORK_DEFS` | Network definitions for iperf client | - | Yes (for iperf) |
| `SKIP_IPERF_MACHINE_CONFIG` | Skip machine config deployment | `false` | No |

### Container Images

#### Default Images (Connected Environment)

- **Stress**: `quay.io/rh_ee_apalanis/fedora-stress-ng`
- **Web Apps**: `quay.io/rh_ee_apalanis/sampleapp`
- **kubectl**: `quay.io/rh_ee_apalanis/kubectl`
- **iperf**: `quay.io/micosta/iperf3`
- **curl**: `quay.io/micosta/curl`

#### Disconnected Environment

When `REGISTRY` is set, all images will be pulled from the specified registry with the same image names.

## Deployment

### Basic Deployment

```bash
# Set required environment variables for iperf (if using network testing)
export IPERF_SERVER_IP="192.168.1.100"
export IPERF_SUBNET="192.168.1.0/24"
export IPERF_SERVER_NETWORK_DEFS='[{"name": "server-net"}]'
export IPERF_CLIENT_NETWORK_DEFS='[{"name": "client-net"}]'

# Optional: Skip machine config if modules already loaded
# export SKIP_IPERF_MACHINE_CONFIG=true

# For disconnected environments use the `REGISTRY` env var
# export REGISTRY='registry.change.me.local:5000'

# Deploy the workload
kube-burner init --config cu-du-intensive.yaml
```

### Cleanup

```bash
# Remove the workload
kube-burner init --config cu-du-intensive-remove.yaml
```

## Network Testing (iperf)

The workload includes optional network performance testing using iperf3:

### Features

- **Server-Client Architecture**: Dedicated iperf server and client pods
- **Custom Networking**: Supports SR-IOV and custom network configurations
- **Security**: Custom SecurityContextConstraints and ServiceAccount
- **Kernel Modules**: Automatic loading of required netfilter modules

### Configuration Requirements

1. **Network Definitions**: Must provide network configurations for both server and client
2. **IP Configuration**: Server IP and subnet must be specified
3. **Machine Config**: Automatically applied unless skipped

### Example Network Configuration

```bash
export IPERF_SERVER_NETWORK_DEFS='[
  {
    "network": {
      "name": "sriov-network-server",
      "namespace": "openshift-sriov-network-operator"
    }
  }
]'

export IPERF_CLIENT_NETWORK_DEFS='[
  {
    "network": {
      "name": "sriov-network-client",
      "namespace": "openshift-sriov-network-operator"
    }
  }
]'
```

## Performance Characteristics

- **CPU**: Multi-threaded stress testing with configurable intensity
- **Memory**: Virtual memory allocation and stress
- **Primary Network**: HTTP traffic via probes and curl operations,
- **Secondary Network**: iperf throughput testing
- **Storage**: File I/O operations and persistent volume usage
- **API Server**: kubectl get operations and RBAC activities

## Monitoring and Verification

### Key Metrics to Monitor

- Pod startup and running status across all namespaces
- Resource utilization (CPU, memory, storage)
- Network throughput (iperf results)
- API server response times
- Storage I/O performance

### Verification Commands

```bash
# Check all workload pods
oc get pods -A -l app.kubernetes.io/part-of=kube-burner

# Monitor resource usage
oc top pods -A

# Check iperf results (if deployed)
oc logs -n workload-1 -l app=iperf-client
oc logs -n workload-1 -l app=iperf-server
```

## Troubleshooting

### Common Issues

1. **iperf pods not starting**: Check if required kernel modules are loaded
2. **Storage pods pending**: Verify storage class availability
3. **Network connectivity issues**: Verify network configurations and SR-IOV setup
4. **Image pull failures**: Check registry connectivity and credentials

### Debug Commands

```bash
# Check machine config status (if iperf enabled)
oc get machineconfig

# Verify kernel modules
lsmod | grep nft

# Check network attachments
oc get network-attachment-definitions -A
```

## Customization

The workload supports extensive customization through template variables and environment settings. Refer to the template files in the `templates/` directory for specific customization options for each component type.

## Related Files

- `cu-du-intensive.yaml` - CU+DU workload configuration
- `cu-du-intensive-remove.yaml` - Cleanup configuration
- `templates/` - Kubernetes object templates
