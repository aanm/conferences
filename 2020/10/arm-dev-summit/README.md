# Workshop instructions

## Cilium Image Build

### Clone of github.com/cilium/cilium

```bash
mkdir -p go/src/github.com/cilium
cd go/src/github.com/cilium
git clone https://github.com/cilium/cilium.git
cd cilium
git checkout v1.9.0-rc0
``` 

### Docker >= 19.03 w/ buildx

Go to https://github.com/docker/buildx/releases

Download for your OS

```bash
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx
export DOCKER_CLI_EXPERIMENTAL=enabled
```

### Public Container Image Repository

Register in https://hub.docker.com/ and login in your machine.

```bash
docker login
```

### Build & Push

```bash
make -C images \
  cilium-image \
  operator-image \
  PUSH=true \
  REGISTRIES=docker.io/<your-docker-username>
```

## Test image built in the previous step

SSH into the VM using the private SSH key:

```bash
$ ssh -i "~/.ssh/arm_dev_summit" ubuntu@18.215.238.179
```

## Deploying Cilium in your cluster

`helm repo add cilium https://helm.cilium.io`

```bash
helm install cilium cilium/cilium \
     --version v1.9.0-rc0 \
     --namespace kube-system \
     --set config.disableEnvoyVersionCheck=true \
     --set global.ipam.operator.clusterPoolIPv4PodCIDR=172.20.0.0/16 \
     --set agent.image=docker.io/aanm/cilium-dev:v1.9.0-rc0 \
     --set operator.image=docker.io/aanm/operator-dev:v1.9.0-rc0
```