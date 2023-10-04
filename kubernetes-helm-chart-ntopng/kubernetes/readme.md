$ kubectl create -f namespace.yaml
namespace/ntopng created

$ cd ~/projects/pi4-ntopng/kubernetes-helm-chart-ntopng/kubernetes
$ helm upgrade --namespace ntopng ntopng .

