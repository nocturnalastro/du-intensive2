# Loads CPU and RAM in a guaranteed POD

Deployment of a guaranteed POD with stress-ng by default it will stress CPU and Memory

## deployment.yaml vars

| Param            | Default                                          | Description                            |
|------------------|--------------------------------------------------|----------------------------------------|
| CPULimit         | 32000m                                           | resources cpu request and limit        |
| MemoryLimit      | 1024M                                            | resources memory request and limit     |
| HugePagesLimit   | 16Gi                                             | resources huge pages limit and request |
| Env              | CPUStress, 32                                    | Env for stress-ng container            |
|                  | VMStress, 1                                      |                                        |
|                  | VMStessBytes, 512M                               |                                        |
| volumes          |                                                  | volumes for stress-ng container        |
| runtimeClassName | "performance-openshift-node-performance-profile" | sets runtimeClassName                  |

### volumes

| Param         | Required |
|---------------|----------|
| name          | yes      |
| type          | yes      |
| path          | no       |

## configmap.yaml vars

| Param         | Default                                   | Description               |
|---------------|-------------------------------------------|---------------------------|
| group         |                                           | Modifies name             |
| data          | {"password": "Zm9vb29vb29vb29vb29vbwo="}  | Sets data                 |

## secret.yaml vars

| Param         | Default                                  | Description               |
|---------------|------------------------------------------|---------------------------|
| group         |                                          | Modifies name             |
| data          | {"data.yaml": {"a": 1, "b": 2, "c": 3}}  | Sets data                 |

## service.yaml vars

| Param         | Default  | Description               |
|---------------|----------|---------------------------|
| port          | 80       | port                      |
| targetPort    | 80       | targetPort                |
