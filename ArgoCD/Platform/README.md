
---

# ArgoCD 배포 가이드

> **목차**
> 1. [개요](#개요)  
> 2. [변경된 ArgoCD Values 상세](#변경된-argocd-values-상세)  
> 3. [Helm Chart 배포 방법](#helm-chart-배포-방법)  
> 4. [GKE Ingress 배포](#gke-ingress-배포)  
> 5. [추가 참고 사항](#추가-참고-사항)

---

## 개요

이 문서는 ArgoCD를 Helm Chart를 이용하여 배포하는 과정을 정리한 가이드입니다.  
아래 변경된 Values 파일(`argocd-dev-values.yaml`)을 통해 ArgoCD 설정을 커스터마이징하고, GKE 환경에서 Ingress와 함께 안전하게 배포하는 방법을 안내합니다.

---

## 변경된 ArgoCD Values 상세

### 1. Node Selector
```yaml
nodeSelector:
  cloud.google.com/gke-nodepool: GKE_NODEPOOL
```
- ArgoCD 서버가 특정 Node Pool에서 동작하도록 설정하였습니다.  
- 기본값은 `{}`로, 글로벌 설정(`global.nodeSelector`)을 따릅니다.

### 2. configs.params
```yaml
configs:
  params:
    server.insecure: true
```
- `server.insecure` 값을 `true`로 지정하여, ArgoCD 서버가 HTTPS 대신 HTTP로 동작하도록 설정했습니다.  
- 내부망에서 테스트용으로 사용 시 편리하지만, 보안을 위해 운영환경에서는 `false`로 설정하는 것을 권장합니다.

### 3. Server > Service Annotations
```yaml
server:
  service:
    annotations:
      cloud.google.com/neg: '{"ingress": true}'
      cloud.google.com/backend-config: '{"ports": {"http":"BACKEND_CONFIG_NAME"}}'
```
- **`cloud.google.com/neg: '{"ingress": true}'`**: GCE의 네트워크 엔드포인트 그룹(NEG) 사용 설정을 위해 추가했습니다.  
- **`cloud.google.com/backend-config: '{"ports": {"http":"BACKEND_CONFIG_NAME"}}'`**: BackendConfig 리소스와 포트를 매핑하여 Cloud Armor, SSL Policy 등을 적용하는 데 사용됩니다.  

---

## Helm Chart 배포 방법

아래 명령어를 통해 Helm Chart 저장소를 추가 및 업데이트한 뒤, `argocd-values.yaml`(또는 `argocd-dev-values.yaml`) 파일을 사용해 ArgoCD를 배포할 수 있습니다.

```bash
# Argo Helm Repo 추가
helm repo add argo https://argoproj.github.io/argo-helm

# 업데이트
helm repo update

# ArgoCD 설치
helm install argocd -n argocd-system argo/argo-cd \
  -f argocd-values.yaml
```

> **Tip:**  
> - `-n argocd-system` 네임스페이스가 존재하지 않는다면 `kubectl create namespace argocd-system` 명령으로 먼저 생성해야 합니다.  
> - 필요에 따라 `argocd-values.yaml` 대신 `argocd-dev-values.yaml` 파일을 사용할 수 있습니다.

---

## GKE Ingress 배포

### 1. Ingress 리소스 배포
Ingress를 통해 외부에서 ArgoCD에 접근할 수 있습니다. (예: `argocd-dev-ingress.yaml`)
```yaml
# 예시 argocd-dev-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-dev-ingress
  annotations:
    # Ingress 관련 설정 (예: Static IP, SSL, Cloud Armor, etc.)
spec:
  rules:
    - host: argocd.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
```

### 2. ComputeSSLPolicy & Cloud Armor 생성
- **Compute SSL Policy**: TLS/SSL 연결에 대한 보안 정책을 적용합니다.  
- **Cloud Armor**: 다양한 보안 규칙을 적용하여 공격 트래픽을 차단할 수 있는 방화벽 정책을 설정합니다.

> 필요한 경우 별도 YAML 혹은 gcloud CLI를 통해 리소스를 생성하고, Ingress Annotations 또는 `BackendConfig`를 통해 적용합니다.

---

## 추가 참고 사항

- **보안**:  
  - `server.insecure: true` 옵션은 보안성이 낮아 운영 환경에서는 사용을 지양해야 합니다.  
  - GKE Ingress에서 SSL이 적용되지 않았다면, 보안 리스크가 존재할 수 있습니다.

- **확장성**:  
  - Node Pool 라벨을 변경하면 서비스가 특정 노드 풀에서만 동작하도록 고정되는 점을 유의하세요.  
  - 고가용성을 위해 여러 Node Pool에 걸쳐 분산 배치를 권장합니다.

- **기타**:  
  - ArgoCD 버전에 따라 지원되는 Helm 버전이 다를 수 있으므로, **Helm**과 **ArgoCD** 버전을 사전에 확인하세요.  
  - Cloud Armor와 SSL Policy는 프로젝트의 네트워크 및 보안 요구 사항에 맞춰 세밀하게 조정해야 합니다.

