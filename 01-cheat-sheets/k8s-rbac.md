# Kubernetes RBAC – Verbs, Resources & API Groups

## 🔹 Verbs – Hành động thường dùng trong RBAC

| Verb               | Mô tả                                                  |
| ------------------ | ------------------------------------------------------ |
| `get`              | Xem chi tiết 1 tài nguyên (`kubectl get pod nginx`)    |
| `list`             | Liệt kê danh sách (`kubectl get pods`)                 |
| `watch`            | Theo dõi realtime (`kubectl get pod -w`)               |
| `create`           | Tạo mới tài nguyên (`kubectl create`, `kubectl apply`) |
| `update`           | Cập nhật toàn bộ tài nguyên                            |
| `patch`            | Cập nhật một phần (`kubectl patch`, controller update) |
| `delete`           | Xóa tài nguyên                                         |
| `deletecollection` | Xoá hàng loạt (`kubectl delete pods --all`)            |
| `impersonate`      | Mạo danh user khác – dùng cho OIDC hoặc audit          |
| `bind`             | Cho phép bind Role/ClusterRole – rất nhạy cảm          |
| `escalate`         | Cho phép cấp quyền cao hơn – nguy hiểm                 |
| `use`              | Dùng resource liên quan như PSP hoặc SCC               |

---

## 🔹 Resource + API Group thông dụng

| Resource                                                   | apiGroup                    | Mô tả                |
| ---------------------------------------------------------- | --------------------------- | -------------------- |
| `pods`, `services`, `endpoints`                            | `""` (core)                 | Cơ bản, hay dùng     |
| `configmaps`, `secrets`                                    | `""` (core)                 | Quản lý cấu hình     |
| `persistentvolumeclaims`                                   | `""` (core)                 | PVC cho volume       |
| `deployments`, `replicasets`, `statefulsets`, `daemonsets` | `apps`                      | Workload             |
| `jobs`, `cronjobs`                                         | `batch`                     | Tác vụ định kỳ       |
| `ingresses`, `networkpolicies`                             | `networking.k8s.io`         | Ingress và network   |
| `roles`, `rolebindings`                                    | `rbac.authorization.k8s.io` | RBAC trong namespace |
| `clusterroles`, `clusterrolebindings`                      | `rbac.authorization.k8s.io` | RBAC toàn cụm        |
| `customresourcedefinitions`                                | `apiextensions.k8s.io`      | CRD                  |
| `nodes`, `namespaces`, `persistentvolumes`                 | `""` (core)                 | Resource toàn cụm    |
| `serviceaccounts`                                          | `""` (core)                 | Pod hoặc CI/CD       |
| `events`                                                   | `""` (core)                 | Log sự kiện          |

---

## 🔹 Một số CRD phổ biến

| Resource                          | apiGroup                   | Từ đâu                |
| --------------------------------- | -------------------------- | --------------------- |
| `prometheuses`, `servicemonitors` | `monitoring.coreos.com`    | kube-prometheus-stack |
| `certificates`, `issuers`         | `cert-manager.io`          | cert-manager          |
| `applications`                    | `argoproj.io`              | ArgoCD                |
| `rollouts`                        | `argoproj.io`              | Argo Rollouts         |
| `externalsecrets`                 | `external-secrets.io`      | External Secrets      |
| `workflows`                       | `argoproj.io`              | Argo Workflows        |
| `repositories`, `charts`          | `source.toolkit.fluxcd.io` | FluxCD                |

---

## 🔹 Verb Combo Gợi ý

| Tên Combo       | Verbs                                                    | Dùng khi              |
| --------------- | -------------------------------------------------------- | --------------------- |
| `read-only`     | `["get", "list", "watch"]`                               | Dev chỉ đọc           |
| `edit-basic`    | `["get", "list", "watch", "create", "update", "delete"]` | Dev deploy app        |
| `full-control`  | `["*"]`                                                  | Admin trong namespace |
| `cluster-admin` | `["*"]` + ClusterRole                                    | Toàn cụm              |
