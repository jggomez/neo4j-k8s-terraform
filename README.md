# Neo4j k8s cluster

This repository contains everything related to neo4j on K8s. Contains the following.

- Installing neo4j on k8s manually with Helm.
- Installing neo4j on k8s with Terraform.
- Update of neo4j nodes because it is necessary to change the configuration properties.
- Creating backups and restore offline mode.
- Creating backups and restore online mode.
- Basic commands for monitoring neo4j cluster.

## 1. Installing neo4j on k8s manually with Helm.

You can follow the official Neo4j documentation

[Quickstart: Deploy a Neo4j cluster](https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-cluster/)

First, create the cluster

```
gcloud container clusters create gke-neo4j-dev --num-nodes=3 --machine-type "e2-standard-4” --zone="us-central1-c"
```

Create compute disk on GCP

```
gcloud compute disks create --size 60Gi --type pd-ssd "core-disk-1"
gcloud compute disks create --size 60Gi --type pd-ssd "core-disk-2”
gcloud compute disks create --size 60Gi --type pd-ssd "core-disk-3”
```

Obtain k8s cluster credentials

```
gcloud container clusters get-credentials gke-neo4j-dev --zone="us-central1-a"
Or
gcloud container clusters get-credentials gke-neo4j-prd --zone="us-central1-a"
```

Create the basic values of the yaml files with the properties for each core 

```
core-1.values.yaml
core-2.values.yaml
core-3.values.yaml
```

Install the Neo4j core nodes with Helm

```
helm install core-1 neo4j/neo4j-cluster-core -f core-1.values.yaml
helm install core-2 neo4j/neo4j-cluster-core -f core-2.values.yaml
helm install core-3 neo4j/neo4j-cluster-core -f core-3.values.yaml
```

Install the load balancer

```
helm install lb neo4j/neo4j-cluster-loadbalancer --set neo4j.name=gke-neo4j-dev
```

## 2. Neo4j k8s cluster - Terraform Scripts

This step contains the terraform scripts to install neo4j on kubernetes. Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

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

## 3. Update of neo4j nodes because it is necessary to change the configuration properties

Change the values you need in the yaml values file

[Configure a Neo4j Helm deployment](https://neo4j.com/docs/operations-manual/current/kubernetes/configuration/)

```
helm upgrade core-1 neo4j/neo4j-cluster-core -f core-1.values.yaml
helm upgrade core-2 neo4j/neo4j-cluster-core -f core-2.values.yaml
helm upgrade core-3 neo4j/neo4j-cluster-core -f core-3.values.yaml
```

## 4. Creating backups and restore OFFLINE mode.

[kubernetes-neo4j-dump-load-offline-mode](https://neo4j.com/docs/operations-manual/current/kubernetes/maintenance/#kubernetes-neo4j-dump-load)

Set the correct project with gcloud and obtain credentials of the k8s cluster

```
gcloud config set project wordboxdev
gcloud container clusters get-credentials gke-neo4j-dev --zone="us-central1-a"
```

You must put Neo4j pods into offline maintenance mode. Change the following property in yaml values file

```
offlineMaintenanceModeEnabled: true
```

and upgrade with Helm. Please repeat this with all nodes

```
helm upgrade core-1 neo4j/neo4j-cluster-core -f core-1.values.yaml
```

Remember to change the property to false when you are done creating a backup or restoring a backup

### 4.1  Creating backups offline mode

Enter to a pod for example core-1-0 with the following command

```
kubectl exec -it core-1-0 -- bash
```

Create backup therefore the dump file and exit the container

```
neo4j-admin dump --expand-commands --database=lessons --to /backups/lessons.dump
```

Copy this file to local machine

```
kubectl cp core-1-0:/var/lib/neo4j/lessons.dump backups/lessons.dump
```

And upload this file to GCP storage

```
gsutil cp lessons.dump gs://backups-wordbox
```

### 4.2  Restore backups offline mode

Enter to a pod for example core-1-0 with the following command

```
kubectl exec -it core-1-0 -- bash
```

Login to Neo4j instance with the cypher-shell

```
cypher-shell -u neo4j -p PASWWORD -d system
```

Delete the database you want to restore

```
DROP DATABASE lessons;
```


**You must put Neo4j pods into offline maintenance mode. Change the following property in yaml values file**


Enter all pods, for example core-1-0 with the following command

```
kubectl exec -it core-1-0 -- bash
```

Download the backup inside the container

```
wget URL_PUBLIC
```

Load a backup

```
neo4j-admin load --expand-commands --database=lessons --from lessons.dump
```

```
Repeat the load from a backup on all core nodes
```

Create the database you just restored (This step only in one container)

```
CREATE DATABASE lessons;
```


## 5. Creating backups and restore ONLINE mode.

[kubernetes-neo4j-backup-restore-online-mode]([https://neo4j.com/docs/operations-manual/current/kubernetes/maintenance/#kubernetes-neo4j-dump-load](https://neo4j.com/docs/operations-manual/current/kubernetes/maintenance/#kubernetes-neo4j-backup-restore))

Set the correct project with gcloud and obtain credentials of the k8s cluster

```
gcloud config set project wordboxdev
gcloud container clusters get-credentials gke-neo4j-dev --zone="us-central1-a"
```

### 5.1  Creating backups online mode

You must create a temporary pod to create a backup

```
kubectl run backup --rm -it --image "neo4j:4.4.8-enterprise" -- bash
```

Create a backup inside this container 

```
bin/neo4j-admin backup --from=core-1-admin.default.svc.cluster.local:6362 --database=lessons --backup-dir=. --expand-commands
```

Copy this backup-directory to local machine in another console window

```
kubectl cp backup:/var/lib/neo4j/lessons backup-lessons/
```

Compress a backup-directory

```
tar -czvf lessson-backup.tar.gz backup-lessons/
```

And upload this file to GCP storage

```
gsutil cp lessson-backup.tar.gz gs://backups-wordbox
```

### 5.2  Restore backups online mode

Enter to a pod for example core-1-0 with the following command

```
kubectl exec -it core-1-0 -- bash
```

Login to Neo4j instance with the cypher-shell

```
cypher-shell -u neo4j -p PASWWORD -d system
```

Delete the database you want to restore

```
DROP DATABASE lessons;
```

Download the backup inside the container

```
wget URL_PUBLIC
```

Unzip the backup-directory

```
tar -xvf lessson-backup.tar.gz
```

Restore a backup

```
neo4j-admin restore --database=lessons --from=/backups/lesssons --expand-commands
```

```
Repeat the restore from a backup on all core nodes
```

Create the database you just restored (This step only in one container)

```
CREATE DATABASE lessons;
```

## 6. Basic commands for monitoring neo4j cluster.

Restart Neo4j

```
kubectl rollout restart statefulset/<neo4j-statefulset-name>
kubectl rollout restart statefulset/core-1
kubectl rollout restart statefulset/core-2
kubectl rollout restart statefulset/core-3
```

Copy to pods

```
kubectl cp file default/core-1-0:/plugins/
```

Obtain the pods

```
kubectl get pods
```

Get the services

```
kubectl get services
```

Complete info about a pod

```
kubectl describe service lb-neo4j
```

Get the logs of a container

```
kubectl exec core-1-0 -- tail /logs/neo4j.log
```

neo4j URL browser

```
http://URL:7474/browser
```


## Reference

- [Quickstart: Deploy a cluster](https://neo4j.com/docs/operations-manual/current/kubernetes/quickstart-cluster/)
- [Terraform GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Configure a Neo4j Helm deployment](https://neo4j.com/docs/operations-manual/current/kubernetes/configuration/)


