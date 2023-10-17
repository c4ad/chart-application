# chart-application

This repository contains the Helm chart for deploying our backend application on a Kubernetes cluster.

## How to use

1. Clone this repository to your local machine.
2. Create a `values.yaml` file based on the provided `values.yaml` example located at the root of this repository. Customize the values in your `values.yaml` file to match your desired configuration.
3. Ensure you have [Helm](https://helm.sh/) installed on your machine.
4. To install the chart with the release name `my-release`, run the following command from the root of the repository, replacing `./path/to/your/values.yaml` with the path to your `values.yaml` file:

```bash
helm install my-release . -f ./path/to/your/values.yaml
```

## Configuration

The following table lists the configurable parameters of the chart and their default values from `values.yaml`.

| Parameter                  | Description                                   | Default             |
|----------------------------|-----------------------------------------------|---------------------|
| `app.name`                 | Name of the application                       | `api-service`       |
| `image.repository`         | Image repository                              | `{}`                |
| `image.pullPolicy`         | Image pull policy                             | `IfNotPresent`      |
| `image.tag`                | Image tag                                     | `""`                |
| `deployment.replicaCount`  | Number of replica pods to deploy             | `1`                 |
| `service.type`             | Kubernetes Service type                       | `ClusterIP`         |
| `service.port`             | Service port                                  | `80`                |
| `service.targetPort`       | Target port on the pods                       | `8080`              |
| `ingress.enabled`          | Enable ingress controller resource            | `false`             |
| `serviceAccount.create`    | Specifies whether a ServiceAccount should be created | `true`      |
| `resources`                | CPU/Memory resource requests/limits           | `{}`                |
| `autoscaling.enabled`      | Enable Horizontal Pod Autoscaler             | `true`              |
| ...                        | ...                                           | ...                 |

Refer to the comments in the example `values.yaml` for more details on configuring individual parameters.

## Updating the Chart

To update your deployment with new configurations, you can upgrade your release with the following command:

```bash
helm upgrade my-release . -f ./path/to/your/values.yaml
```