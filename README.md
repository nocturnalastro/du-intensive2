## Kube-burner-ocp based template for a RAN DU workload

### Pre-requisites to deploy workload:

Mirror this container to registry in the hub (if spoke is disconnected)
https://github.com/abraham2512/fedora-stress-ng/pkgs/container/fedora-stress-ng

Ensure $REGISTRY is set up in the environment

Deploy DU workload with RAN RDS specs
kube-burner-ocp init --config du-workload.yml