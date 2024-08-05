# weaviate-operator
A Kubernetes Operator to automate the management of Weaviate Database Clusters
# Weaviate Operator

The Weaviate Operator is a Kubernetes Operator designed to automate the management of Weaviate Database Clusters.

## Prerequisites

Before getting started, make sure you have the following prerequisites:

- Go through the installation guide.
- Ensure that your user is authorized with cluster-admin permissions.
- Have an accessible image registry for various operator images (e.g., hub.docker.com, quay.io) and be logged in to your command line environment.

## Overview

The Weaviate Operator wraps the [weaviate-heml](https://github.com/weaviate/weaviate-helm) Helm charts, craeting a CRD and CRs which allow passing specific values to configure the application.

## Create a new project

1. To create a new namespace weaviate, follow these steps:

```shell
kubectl create ns weaviate
```

This will start the weaviate-operator .

2. Review the Weaviate Helm Chart that was created by the SDK. This chart contains templates for a simple Weaviate release.

3. Customize the Weaviate CR spec by modifying the `config/samples/apps_v1alpha1_cluster.yaml` file. You can override the default values defined in the Helm chart's `values.yaml` file.


## Run the operator

There are multiple ways to run the operator:

1. Run the operator locally outside the cluster by executing the following command:

```shell
make install run
```

2. Run the operator as a Deployment inside the cluster by executing the following command:

```shell
make deploy
```

3. Deploy the operator with OLM (Operator Lifecycle Manager) in bundle format. First, install OLM using the `operator-sdk olm install` command. Then, bundle your operator, build and push the bundle image, and finally run your bundle using the `operator-sdk run bundle` command.

## Create a Weaviate CR

To create the Weaviate CR, apply the modified `config/samples/apps_v1alpha1_cluster.yaml` file:

```shell
kubectl apply -f config/samples/apps_v1alpha1_cluster.yaml
```

The operator will create the statefulset for the CR based on the specified replica count and other configurations.

## Troubleshooting

If you encounter any issues, you can check the operator logs using the following command:

```shell
kubectl logs deployment.apps/weaviate-operator-controller-manager -n weaviate-operator-system -c manager
```

You can also check the CR status and events using the following command:

```shell
kubectl describe cluster.apps.weaviate.io
```

## Cleanup

To clean up the resources, delete the custom resource using the following command:

```shell
kubectl delete -f config/samples/apps_v1alpha1_cluster.yaml
```

Then, undeploy the operator using the `make undeploy` command.

## Next steps

Once you have successfully deployed and tested the Weaviate Operator, you can explore advanced features and consider packaging and distributing the operator with OLM.
