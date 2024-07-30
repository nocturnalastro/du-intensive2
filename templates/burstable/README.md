# Stress CPU, RAM and HDD

Deployment with stress-ng by default it will stress CPU, Memory and Disk IO.

## deployment.yaml vars

| Param            | Default                                          | Description                     |
|------------------|--------------------------------------------------|---------------------------------|
| CPURequest       | 1000m                                            | resources cpu request           |
| MemoryRequest    | 1024M                                            | resources memory request        |
| CPULimit         | CPURequest, 2000m                                | resources cpu limit             |
| MemoryLimit      | MemoryRequest, 2048M                             | resources memory limit          |
| Env              | CPUStress, 1                                     | Env for stress-ng container     |
|                  | VMStress, 1                                      |                                 |
|                  | VMStessBytes, 512M                               |                                 |
|                  | HDDStress, 1                                     |                                 |
|                  | HDDStressBytes, 25                               |                                 |
| volumes          |                                                  | volumes for stress-ng container |
| runtimeClassName | "performance-openshift-node-performance-profile" | sets runtimeClassName           |

### volumes

| Param         | Required |
|---------------|----------|
| name          | yes      |
| type          | yes      |
| path          | no       |

## pv.yaml vars

| Param         | Default              | Description               |
|---------------|----------------------|---------------------------|
| group         |                      | Modifies name             |
| class         | manual               | storageClassName          |
| capacity      | 20Gi                 | storage capacity          |
| path          | /mnt/data            | hostPath                  |

## pvc.yaml vars

| Param         | Default              | Description               |
|---------------|----------------------|---------------------------|
| group         |                      | Modifies name             |
| class         | manual               | storageClassName          |
| capacity      | 20Gi                 | storage capacity          |
