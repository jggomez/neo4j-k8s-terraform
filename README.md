# Neo4j k8s cluster on GKE - Terraform Scripts

## Description

This repository contains the terraform scripts to install neo4j on kubernetes. Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

## Steps to use these scripts

1- Copy these files inside GCP, you can use Cloud Shell. If you use cloud shell, you don't need to install GCP CLI, helm and you don't need to authenticate to GCP.

2- Inside cloud shell, download this repository

3- You must create the cluster and the disks for that you must execute the following commands.

For this you use the file neo4j-k8s-cluster.tf, you need to check the Google service account and attributes for the cluster.

```
neo4j-k8s-cluster.tf
```

This command is used to initialize a working directory containing Terraform configuration files
```
terraform init
```

This command executes the actions proposed in a Terraform plan
```
terraform apply
```

4- Check out the files to create the main neo4j nodes, these contain attributes for each node. For this case, we are going to create three core nodes. If you want more information about these files you can go to the following link

[Create Helm deployment values files](https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-cluster/create-value-file/)

5- Before running the commands, create a kubeconfig entry for neo4j-gke-cluster. You can create this kubeconfig with the following command:

Remember to set the correct cluster name and zone

```
gcloud container clusters get-credentials (CLUSTE-NAME) --zone="us-central1-a"
```

6- There are three terraform files for each value file

```
neo4j-k8s-cluster-core-1-helm.tf

neo4j-k8s-cluster-core-2-helm.tf

neo4j-k8s-cluster-core-3-helm.tf
```

Cloud Shell allows you to have multiple consoles, you need to open three for this case because it will run at the same time to create core nodes. Then, execute the following commands in each window at the same time:


```
terraform init
terraform apply
```

Please wait to finish successfully

7- Finally, create the load balancer. Use the file neo4j-k8s-cluster-lb.tf

```
neo4j-k8s-cluster-lb.tf
```

And execute the same terraform commands

```
terraform init
terraform apply
```

## Reference

- [Quickstart: Deploy a cluster](https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-cluster/)
- [Terraform GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)


Made with ❤ by  [jggomez](https://devhack.co).

[![Twitter Badge](https://img.shields.io/badge/-@jggomezt-1ca0f1?style=flat-square&labelColor=1ca0f1&logo=twitter&logoColor=white&link=https://twitter.com/jggomezt)](https://twitter.com/jggomezt)
[![Linkedin Badge](https://img.shields.io/badge/-jggomezt-blue?style=flat-square&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/jggomezt/)](https://www.linkedin.com/in/jggomezt/)
[![Medium Badge](https://img.shields.io/badge/-@jggomezt-03a57a?style=flat-square&labelColor=000000&logo=Medium&link=https://medium.com/@jggomezt)](https://medium.com/@jggomezt)

