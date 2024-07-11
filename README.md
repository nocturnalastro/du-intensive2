## Kube-burner-ocp based template for a RAN DU workload

### Steps to deploy workload on an Openshift SNO:

* Ensure $REGISTRY is set up in the environment

* Mirror this container to registry in the hub (if spoke is disconnected) [fedora-stress-ng](https://github.com/abraham2512/fedora-stress-ng/pkgs/container/fedora-stress-ng)

* Deploy DU workload with RAN RDS specs
`kube-burner-ocp init --config du-workload.yml`

* Attach kubelet traffic client/servers to DU
`kube-burner-ocp init --config kubelet-stress.yml`