[all]
thanh-k8s-master-0 ansible_host=192.168.137.21
thanh-k8s-worker-0 ansible_host=192.168.137.22
thanh-k8s-worker-1 ansible_host=192.168.137.23

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr

[kube_control_plane]
thanh-k8s-master-0

[etcd]
thanh-k8s-master-0

[kube_node]
thanh-k8s-worker-0
thanh-k8s-worker-1

[calico_rr]
