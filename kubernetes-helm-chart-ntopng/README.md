# kubernetes-helm-chart-ntopng
Kubernetes helm chart for Ntopng

Original: https://github.com/MySocialApp/kubernetes-helm-chart-ntopng.git

```bash
$ kubectl create -f ./kubernetes/namespace.yaml

$ helm install --debug --namespace ntopng ntopng ./kubernetes
install.go:193: [debug] Original chart version: ""
install.go:210: [debug] CHART PATH: /home/gdha/projects/pi4-ntopng/kubernetes-helm-chart-ntopng/kubernetes

client.go:133: [debug] creating 5 resource(s)
NAME: ntopng
LAST DEPLOYED: Fri Mar  3 13:58:27 2023
NAMESPACE: ntopng
STATUS: deployed
REVISION: 1
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
ntopngConfig: |-
  --disable-login=1
  --dns-mode=3
  # Limit memory usage
  --max-num-flows=200000
  --max-num-hosts=250000
  #--interface=xxxxxx
  --no-promisc
ntopngImageName: ghcr.io/gdha/pi4-ntopng
ntopngImageVersion: v1.5
ntopngNodeSelector:
  kubernetes.io/os: linux
ntopngResources: null
ntopngService:
  port: 80
  type: LoadBalancer

HOOKS:
MANIFEST:
---
# Source: ntopng/templates/ghcr-secret.yaml
# kubectl create secret docker-registry dockerconfigjson-github-com --docker-server=ghcr.io  --docker-username=gdha --docker-password=$(cat ~/.ghcr-token) --dry-run=client -oyaml >ghcr-secret.yaml
# Edit ghcr-secret.yaml and modify namespace and labels in the metadata section.
apiVersion: v1
kind: Secret
metadata:
  name: ntopng-ghrc
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-1.0.0
    release: ntopng
    heritage: Helm
  creationTimestamp: null
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJnaGNy...jghjgjghghgjX1
---
# Source: ntopng/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ntopng
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-1.0.0
    release: ntopng
    heritage: Helm
type: Opaque
---
# Source: ntopng/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ntopng
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-1.0.0
    release: ntopng
    heritage: Helm
data:
  ntopng.conf: |-
    --disable-login=1
    --dns-mode=3
    # Limit memory usage
    --max-num-flows=200000
    --max-num-hosts=250000
    #--interface=xxxxxx
    --no-promisc
---
# Source: ntopng/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ntopng
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-1.0.0
    release: ntopng
    heritage: Helm
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app: ntopng
  ports:
  - name: ntopng
    port: 80
    targetPort: 3000
    protocol: TCP
---
# Source: ntopng/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ntopng
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-1.0.0
    release: ntopng
    heritage: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ntopng
  template:
    metadata:
      labels:
        app: ntopng
        chart: ntopng-1.0.0
        release: ntopng
        heritage: Helm
    spec:
      terminationGracePeriodSeconds: 10
      hostNetwork: true
      nodeSelector:
        kubernetes.io/os: "linux"
      imagePullSecrets:
        - name: ntopng-ghrc
      containers:
      - name: ntopng
        image: ghcr.io/gdha/pi4-ntopng:v1.5
        imagePullPolicy: IfNotPresent
        ports:
        - name: ntopng
          containerPort: 3000
          protocol: TCP
        resources:
            null

        env:
          - name: CONFIG
            value: /ntopng/ntopng.conf
        volumeMounts:
        - name: config
          mountPath: /ntopng
      volumes:
      - name: config
        configMap:
          name: ntopng


gdha@n1:~/projects/pi4-ntopng/kubernetes-helm-chart-ntopng$ kubectl get secrets -n ntopng
NAME                           TYPE                             DATA   AGE
ntopng                         Opaque                           0      18s
ntopng-ghrc                    kubernetes.io/dockerconfigjson   1      18s
sh.helm.release.v1.ntopng.v1   helm.sh/release.v1               1      18s

gdha@n1:~/projects/pi4-ntopng/kubernetes-helm-chart-ntopng$ kubectl get pods -n ntopng -w
NAME                      READY   STATUS              RESTARTS   AGE
ntopng-6979c5b94c-9kc9g   0/1     ContainerCreating   0          44s
ntopng-6979c5b94c-9kc9g   1/1     Running             0          52s

$ kubectl get svc -n ntopng
NAME     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
ntopng   LoadBalancer   10.43.195.118   192.168.0.235   80:31635/TCP   2m57s
```

Once the pod is running (and stays running) you can open with a browser the ntopng application via URL http://192.168.0.235/

<img alt="ntopng application" src="../pictures/ntopng-k3s.png" width="900">

Interesting to see how much resources this pod `ntopng` uses on node n5:

<img alt="ntopng application" src="../pictures/ntopng-resources.png" width="900">


## To remove the ntopng project run:

```
$ helm uninstall --debug --namespace ntopng ntopng
uninstall.go:95: [debug] uninstall: Deleting ntopng
client.go:477: [debug] Starting delete for "ntopng" Service
client.go:477: [debug] Starting delete for "ntopng" Deployment
client.go:477: [debug] Starting delete for "ntopng" ConfigMap
client.go:477: [debug] Starting delete for "ntopng" Secret
client.go:477: [debug] Starting delete for "ntopng-ghrc" Secret
uninstall.go:148: [debug] purge requested for ntopng
release "ntopng" uninstalled
```

