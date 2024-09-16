# Weaviate Operator

The Weaviate Operator is a Kubernetes Operator designed to automate the management of Weaviate Database Clusters.

## Prerequisites

Before getting started, make sure you have the following prerequisites:

- Have a kubernetes cluster.
- Ensure that your user is authorized with cluster-admin permissions.

If you want to deploy a local kubernetes cluster for local testing you can [install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation):
```
brew install kind
```

And start a cluster with:
```
WORKERS=3
cat <<EOF > /tmp/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: weaviate-k8s
nodes:
- role: control-plane
$([ "${WORKERS:-""}" != "" ] && for i in $(seq 1 $WORKERS); do echo "- role: worker"; done)
EOF


kind create cluster --wait 120s --name weaviate-k8s --config /tmp/kind-config.yaml
```

## Overview

The Weaviate Operator wraps the [weaviate-helm](https://github.com/weaviate/weaviate-helm) Helm charts, creating a CRD and CRs which allow passing specific values to configure the application.


## Deploy the operator

There are multiple ways to run the `weaviate-operator`:

1. The easiest way is to apply the one-single-command Manifest:

```shell
kubectl apply -f https://github.com/weaviate/weaviate-operator/releases/download/0.0.2/operator.yaml
```

Other alternative ways to install it is:

1. Run the operator locally outside the cluster by executing the following command inside the `weaviate-operator` repository:

```shell
make install run
```

2. Run the operator as a Deployment inside the cluster by executing the following command inside the `weaviate-operator` repository:

```shell
make deploy
```

In case the image is not available you can build it locally by running first:

```shell
make docker-build
```

This will create locally the image `semitechnologies/weaviate-operator`.

If you have created your cluster via kind, you will have to make that image available inside the cluster:

```shell
kind load docker-image semitechnologies/weaviate-operator:0.0.2  --name weaviate-k8s
```

3. [NOT AVAILABLE YET] Deploy the operator with OLM (Operator Lifecycle Manager) in bundle format. First, install OLM using the `operator-sdk olm install` command. Then, bundle your operator, build and push the bundle image, and finally run your bundle using the `operator-sdk run bundle` command.

## Create a Weaviate CR

To create the Weaviate CR, apply the modified `config/samples/apps_v1alpha1_weaviatecluster.yaml` file:

```shell
kubectl apply -f config/samples/apps_v1alpha1_weaviatecluster.yaml -n weaviate
```

make sure to create the namespace `weaviate` (or any other namespace in which you want you Weaviate nodes to run) in advance:

```shell
kubectl create ns weaviate
```

or simply create your own definition of the WeaviateCluster (based on the [weaviate-helm values.yaml](https://github.com/weaviate/weaviate-helm/blob/master/weaviate/values.yaml)):

```
apiVersion: apps.weaviate.io/v1alpha1
 kind: WeaviateCluster
 metadata:
   name: weaviatecluster-sample
   namespace: weaviate
 spec:
   # Default values copied from <project_dir>/helm-charts/weaviate/values.yaml
   debug: true
   env:
     CLUSTER_DATA_BIND_PORT: 7001
     CLUSTER_GOSSIP_BIND_PORT: 7000
     GOGC: 100
     PROMETHEUS_MONITORING_ENABLED: false
     PROMETHEUS_MONITORING_GROUP: false
     QUERY_MAXIMUM_RESULTS: 100000
     REINDEX_VECTOR_DIMENSIONS_AT_STARTUP: false
     TRACK_VECTOR_DIMENSIONS: false
   image:
     tag: 1.26.1
   replicas: 3
   storage:
     size: 32Gi
```
A new custom resource `weaviatecluster` will be now available:

```shell
kubectl get weaviatecluster -n weaviate
NAME                     AGE
weaviatecluster-sample   13s

```
The operator will create the statefulset for the CR based on the specified replica count and other configurations. Keep in mind that the resources will be created in the namespace you decide, in this example the `weaviate` namespace is used, but you can install it in any other namespace. 

```shell
kubectl get statefulset weaviate -n weaviate
NAME       READY   AGE
weaviate   3/3     65s
```

## Troubleshooting

If you encounter any issues, you can check the operator logs using the following command:

```shell
kubectl logs deployment.apps/weaviate-operator-controller-manager -n weaviate-operator-system -c manager
```

You can also check the CR status and events using the following command:

```shell
kubectl describe weaviateclusters.apps.weaviate.io -n weaviate
```

## Cleanup

To clean up the `weaviatecluster` resources, delete the custom resource using the following command:

```shell
kubectl delete -f config/samples/apps_v1alpha1_weaviatecluster.yaml -n weaviate
```
or deleting it directly:

```shell
kubectl delete weaviatecluster weaviatecluster-sample -n weaviate
```

Then, uninstall the operator either using the single-command manifest:

```shell
kubectl delete -f https://github.com/weaviate/weaviate-operator/releases/download/0.0.2/operator.yaml
```

or using the repo's Makefile, by running the following command inside the `weaviate-operator` repo:

```shell
make undeploy
```

or simply stop the process if you started it via `make install run`.

