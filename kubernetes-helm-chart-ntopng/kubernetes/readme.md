# Special notes on using Helm with ntopng

To protect you GitHub secret we create a `templates/.hidden` directory and then create an `templates/.hidden/ghcr-secret.yaml` file. Be sure to replace your username and we assume your GitHib token is saved as `~/.ghcr-token`.

```bash
$ kubectl create secret docker-registry dockerconfigjson-github-com --docker-server=ghcr.io  --docker-username=gdha --docker-password=$(cat ~/.ghcr-token) --dry-run=client -oyaml >templates/.hidden/ghcr-secret.yaml
```
Edit ghcr-secret.yaml and modify namespace and labels in the metadata section. Under the `templates` directory create a softy-link from `.hidden/ghcr-secret.yaml` to `ghcr-secret.yaml`.

Once that is done you may continue with the following commands:

```bash
$ kubectl create -f namespace.yaml
namespace/ntopng created

$ cd ~/projects/pi4-ntopng/kubernetes-helm-chart-ntopng/kubernetes
$ helm upgrade --namespace ntopng ntopng .
```
