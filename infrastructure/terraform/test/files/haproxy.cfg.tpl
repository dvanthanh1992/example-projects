global
    log         /dev/log    local0
    log         /dev/log    local1 notice
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    tcp
    log                     global
    option                  dontlognull
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s

    maxconn 2000
    fullconn 2000

listen stats
    bind *:9000
    mode http
    stats enable
    stats hide-version
    stats realm Haproxy\ Statistics
    stats uri /haproxy_stats

frontend k8_api_frontend
    bind *:6443
    mode tcp
    option tcplog
    default_backend k8s_api_backend

backend k8s_api_backend
    mode tcp
    option tcp-check
    balance roundrobin
    default-server inter 10s  fall 2 rise 2 downinter 5s slowstart 60s 
    {% for master_ip in master_ips %}
        server master{{ loop.index }} {{ master_ip }}:6443 check
    {% endfor %}

frontend k8s_nodeport_frontend
    bind *:30000-32767
    mode tcp
    option tcplog
    use_backend k8s_nodeport_backend
    maxconn 20000

backend k8s_nodeport_backend
    mode tcp
    option tcp-check
    balance roundrobin
    fullconn 20000
    default-server inter 10s  fall 2 rise 2 downinter 5s slowstart 60s 
    {% for worker_ip in worker_ips %}
        server worker{{ loop.index }} {{ worker_ip }} check port 22
    {% endfor %}


frontend ingress_frontend_80
    bind *:80
    mode tcp
    option tcplog
    use_backend ingress_backend_80

backend ingress_backend_80
    mode tcp
    option tcp-check
    balance roundrobin
    default-server inter 10s  fall 2 rise 2 downinter 5s slowstart 60s 
    {% for worker_ip in worker_ips %}
        server worker{{ loop.index }} {{ worker_ip }} check port 22
    {% endfor %}

frontend ingress_frontend_443
    bind *:443
    mode tcp
    option tcplog
    use_backend ingress_backend_443

backend ingress_backend_443
    mode tcp
    option tcp-check    
    balance roundrobin
    default-server inter 10s  fall 2 rise 2 downinter 5s slowstart 60s 
    {% for worker_ip in worker_ips %}
        server worker{{ loop.index }} {{ worker_ip }} check port 22
    {% endfor %}
