# Creating a arm64 instance in aws

1 - Download terraform https://www.terraform.io/downloads.html

2 - Export the following environment variables

```base
export TF_VAR_aws_access_key="<aws access key>"
export TF_VAR_aws_secret_key="<aws secret key>"
```

3 - Make sure the ssh agent is running: `ssh-agent`

4 - `terraform init .`

5 - `terraform apply -var=number_of_attendees=1`

6 - Retrieve the IP address to connect to the machine

```bash
$ terraform show -json | jq .values.root_module.resources[0].values.public_ip
"18.215.238.179"
```

7 - SSH into the VM using the private SSH key:

```bash
$ ssh -i "~/.ssh/arm_dev_summit" ubuntu@18.215.238.179
```

# Deploying Cilium in your cluster

1 - `helm repo add cilium https://helm.cilium.io`

2 - 

```bash
helm install cilium cilium/cilium \
     --version v1.9.0-rc0 \
     --namespace kube-system \
     --set config.disableEnvoyVersionCheck=true \
     --set global.ipam.operator.clusterPoolIPv4PodCIDR=172.20.0.0/16 \
     --set agent.image=docker.io/aanm/cilium-dev:v1.9.0-rc0 \
     --set operator.image=docker.io/aanm/operator-dev:v1.9.0-rc0
```