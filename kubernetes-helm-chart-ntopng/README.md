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
LAST DEPLOYED: Fri Feb 24 17:08:46 2023
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
ntopngImageVersion: v1.4
ntopngNodeSelector:
  kubernetes.io/os: linux
ntopngResources:
  limits:
    cpu: 1
    memory: 512Mi
  requests:
    cpu: 500m
    memory: 256Mi
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
    chart: ntopng-v1.4
    release: ntopng
    heritage: Helm
  creationTimestamp: null
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJnaGNyLmlvIjp7InVzZXJuYW1lIjoiZ2RoYSIsInBhc3N3b3JkIjoiZ2hwX3V5TzRJcFJyek5qRXNuSU5zdzRENXVWUVVnZGFaUjQ0djRjNiIsImF1dGgiOiJaMlJvWVRwbmFIQmZkWGxQTkVsd1VuSjZUbXBGYzI1SlRuTjNORVExZFZaUlZXZGtZVnBTTkRSMk5HTTIifX19
---
# Source: ntopng/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ntopng
  namespace: ntopng
  labels:
    app: ntopng
    chart: ntopng-v1.4
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
    chart: ntopng-v1.4
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
    chart: ntopng-v1.4
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
    chart: ntopng-v1.4
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
        chart: ntopng-v1.4
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
        image: ghcr.io/gdha/pi4-ntopng:v1.4
        imagePullPolicy: IfNotPresent
        ports:
        - name: ntopng
          containerPort: 3000
          protocol: TCP
        resources:
            limits:
              cpu: 1
              memory: 512Mi
            requests:
              cpu: 500m
              memory: 256Mi

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
```
