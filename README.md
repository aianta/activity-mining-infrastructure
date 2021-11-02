## Requirements

* Kind v0.11.1
* Terraform v1.0.10

## Create a local kind cluster

`kind create cluster --name sa-project --config .kind\kind-config.yml`

## Get cluster context

`kubectl cluster-info --context kind-sa-project`

```
Kubernetes control plane is running at https://127.0.0.1:64451
CoreDNS is running at https://127.0.0.1:64451/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## Configure Kubernetes provider in Terraform

Rename the `terraform-template.tfvars` file to `terrafrom.tfvars` and fill in the variables. 

Variable values for your local kind cluster should be available by running the command:

`kubectl config view --minify --flatten --context=kind-sa-project`

For more details see: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider?in=terraform/use-case

Once you've created your `terraform.tfvars` file, run `terraform init`

## Get the cluster configuration

`kubectl config view --minify --flatten --context=kind-sa-project`


## Create a Spark K8 cluster service account 
You'll need this to run `spark-submit` jobs on your local cluster.

`kubectl create serviceaccount spark`

`kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default`