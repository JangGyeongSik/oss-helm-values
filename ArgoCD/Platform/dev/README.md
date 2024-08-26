# ArgoCD Values 변경 내역

1. argocd-ke1ss-values.yaml
```yaml
# -- [Node selector]
# @default -- `{}` (defaults to global.nodeSelector)
nodeSelector:
  cloud.google.com/gke-nodepool: npg-01-asia-northeast3-a-bear

configs:
  params:
    server.insecure: true

server:
  service:
    annotations:
      cloud.google.com/neg: '{"ingress": true}'
      cloud.google.com/backend-config: '{"ports": {"http":"BACKEND_CONFIG_NAME"}}' 
```

2. Helm Chart 배포 
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd-system argo/argo-cd -f argocd-values.yaml  
```

3. GKE Ingress 배포
 * Ingress Deploy
    * [argocd-ke1ss-common-ingress.yaml](./argocd-ke1ss-common-ingress.yaml)
 * ComputeSSLPolicy & Cloud Armor 생성 w/Config Connector
    - [argocd-ke1ss-dev-ingress.yaml](https://gitlab.wemakeprice.cloud/wish-platform/481965497078/152502355868/prj-dev-wish-ke1ss-6213/-/blob/main/argocd-ke1ss-dev-ingress.yaml)


