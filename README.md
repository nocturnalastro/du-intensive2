# Generic RAN DU Workload

A scalable, fully customizable RAN DU workload deployed with [kube-burner](https://github.com/kube-burner/kube-burner)

#### Default Configuration
| Pod | Number of Pods | Specs | Stress |
|-----|----------------|-------| ------- |
| Guaranteed | 1 pod, 2 containers | - 32 CPU, 1 GiB Memory, 16 GiB HP<br>- 2 configmaps and 4 secrets<br> 1 svc<br> | 32 threads of 100% CPU stress, 512M virtual memory stress |
| BestEffort - web_server | 4 pods, 2 containers each | - 100 mc CPU, 128 Mib Memory<br>- 2 configmaps and 4 secrets<br> | Exposes 8080 port for probes |
| BestEffort - curl_app | 4 pods, 2 containers each | - 100 mc CPU, 128 Mib Memory<br>- 2 configmaps and 4 secrets<br>- Liveness Probes (every 10 secs)| Kubelet stress with probes, ~250 KB per sec n/w traffic on Primary CNI |
| BestEffort - kubectl_pods | 6 pods, 2 containers each | - 100 mc CPU , 128 Mib Memory<br>- 2 configmaps and 4 secrets<br>- 2 kubectl gets (every 5 sec) | Kube-api-server stress with kubectl get, ~10% increase due to workload |
| BestEffort - storageio | 1 pod, 2 containers | - 100 mc CPU , 128 Mib Memory<br>- 2 configmaps and 4 secrets<br>- 1 hdd stress | Storage-io stress with stress-ng |

* Total pods - 15 pods / 30 containers
* 2 config maps and 4 secrets in each pod
* Exec Probes less than 10 in total and frequency >10 secs
* No Exec probes on Gu pod
* Traffic on primary CNI due to workload expected around 350 KB per sec
* kube api-server incremental load due to workload expected to increase by 5-8%

#### Minimum pre-requisites
* Single Node Openshift Cluster with Performance Profile
* kube-burner v1.16.0+

#### Steps to run workload on a RAN DU profile Single Node Openshift Cluster

* Clone this repository and run the following.

    ```shell
    export STORAGE_CLASS="" # Defaults to general
    export NETWORKS="" # SRIOV Networks to use for DPDK container if blank then DPDK container will not be added
    export ACCELERATOR_MODEL="" # Used by DPDK deployment if left blank it wont be added
    export REGISTRY="" # For a disconnected cluster, path to mirrored images in internal hub registry
    export NODE_NAME=$(oc get nodes -ojson | jq .items[0].metadata.name -r) # For SNO with performance profile
    export ENABLE_PTP="" # Set to true if node is ptp-enabled 
    export KUBECONFIG="..."
    kube-burner init --config du-intensive.yaml
    ```

#### Steps to run workload with cpu_utilization tests (internal jenkins pipelines)

* Run the MIRROR_SPOKE_OPERATOR_IMAGES stage in ocp-far-edge-vran-deployment pipeline to mirror necessary test images
* Run the cpu_util test using ocp-far-edge-vran-tests pipeline

## Additional Workload Features

### Enabling PTP Consumer

A PTP consumer can be run on systems with PTP available by setting an env var `ENABLE_PTP` and requires `NODE_NAME`.

### Running DPDK deployment

Running the DPDK pod requires the defintion of the a `NETWORKS` env var. `$NETWORKS` should be a list of objects of the following form:

```json
[
    {
        "network": [1],
        "resource": [2]
    }
]
```

* [1] The structure for the `k8s.v1.cni.cncf.io/networks` annotation.
      It should represent the networks you wish to connect to to the DPDK pod  e.g. `{"name": "myNetwork", "namespace": "otherNs"}`.
      It will be combined into a json list.
* [2] The key for the resource e.g. `openshift.io/pci_sriov_net_myNetwork`.
