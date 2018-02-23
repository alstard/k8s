# k8s - A collection of stuff pertaining to Kubernetes

## Kube Cheat Sheet 
[K8s Command Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Certificate & Secret Generation
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt
openssl dhparam -out certs/dhparam.pem 2048

kubectl create secret tls tls-certificate --key nginx-selfsigned.key --cert nginx-selfsigned.crt
kubectl create secret generic tls-dhparam --from-file=dhparam.pem

## Updated Containers 
* gcr.io/google_containers/defaultbackend:1.4
* gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.15

## Deployments / Configuration 
[Simple Nginx / Helloworld deployments](https://medium.com/@gokulc/setting-up-nginx-ingress-on-kubernetes-2b733d8d2f45)

## Simplified Instructions (Generic - Tested on Google GKE)
* Create New Namespace            - kubectl create -f ingresstest-namespace.json
* Set New Namespace (GKE)         - kubectl config set-context ns-ingress-test --namespace=ns-ingress-test \
                                    --cluster=gke_wts-kubetests_europe-west2-b_ingresstest            --user=gke_wts-kubetests_europe-west2-b_ingresstest
* Set New Namespace (Kops)        - kubectl config set-context ns-ingress-test --namespace=ns-ingress-test \
                                    --cluster=kops1.kops.wulfruntech.uk  --user=kops1.kops.wulfruntech.uk
* Set Context                     - kubectl config use-context ns-ingress-test
* Check New Context               - kubectl config current-context
* Deployment/Service              - kubectl create -f helloworld.yaml
* Deployment/Service              - kubectl create -f default-backend.yaml
* Generate Cert/dhparam           - [see above openssl commands]
* Create k8s secrets #1           - kubectl create secret tls tls-certificate --key nginx-selfsigned.key --cert nginx-selfsigned.crt
* Create k8s secrets #2           - kubectl create secret generic tls-dhparam --from-file=dhparam.pem
* ConfigMap (x3)                  - kubectl apply -f ingress-configmap.yaml
* Replication Controllers (x2)    - kubectl apply -f ingress-rc.yaml
* Ingress Service (changed!)      - kubectl apply -f ingress-svc.yaml
* Deployment/Service              - kubectl create -f nginx-controller.yaml
* Get External IP                 - kubectl get services -o wide nginx-ingress
* curl to default backend         - curl http://<EXTERNAL IP>:<PORT> [response should be: 'default backend - 404']
* Deploy ingress rules            - kubectl apply -f ingress.yaml [need to modify DNS/hosts for api.sample.com]
* test (1)                        - curl -i -X GET http://api.sample.com/mytest
* test (2)                        - curl -i -X POST http://api.sample.com/mytest
* test (3)                        - curl -i -X PUT http://api.sample.com/mytest

## Simplified Instructions (KOPS/AWS) 
* Create New Namespace              - kubectl create -f ingresstest-namespace.json
* Deployment/Service                - kubectl apply -f helloworld.yaml --namespace=ingresstest
* Deployment/Service                - kubectl apply -f default-backend.yaml --namespace=ingresstest
* Generate Cert/dhparam             - [see above openssl commands]
* Create k8s secrets #1             - kubectl create secret tls tls-certificate --key certs/nginx-selfsigned.key \
                                    --cert certs/nginx-selfsigned.crt  --namespace=ingresstest
* Create k8s secrets #2             - kubectl create secret generic tls-dhparam --from-file=certs/dhparam.pem  --namespace=ingresstest
* ConfigMap (x3)                    - kubectl apply -f ingress-configmap.yaml --namespace=ingresstest
* Replication Controllers (x2)      - kubectl apply -f ingress-rc.yaml --namespace=ingresstest
* Ingress Service                   - kubectl apply -f ingress-svc.yaml --namespace=ingresstest
* Deployment/Service                - kubectl apply -f nginx-controller.yaml --namespace=ingresstest
* Get External IP                   - kubectl get services -o wide nginx-ingress --namespace=ingresstest
* curl to default backend           - curl http://<EXTERNAL IP>:<PORT> [response should be: 'default backend - 404']
* Deploy ingress rules              - kubectl apply -f ingress.yaml --namespace=ingresstest
* test (1)                          - curl -i -X GET http://ingresstest.kops.wulfruntech.uk/myass
* test (2)                          - curl -i -X POST http://ingresstest.kops.wulfruntech.uk/myass
* test (3)                          - curl -i -X PUT http://ingresstest.kops.wulfruntech.uk/myass

## Deploying Nginx or Traefik Ingress Controllers

[Walkthrough](https://daemonza.github.io/2017/02/13/kubernetes-nginx-ingress-controller/)


### Kubernetes Service Types 
* ClusterIP - Your service is only exposed internally to the cluster on the internal cluster IP.
  An example would be to deploy Hasicorp’s vault and expose it internally.
* NodePort - Expose the service on the EC2 Instance on the specified port. This will be exposed to the internet.
  Depends on your AWS Security group / VPN rules.
* LoadBalancer - Supported on AWS and Google Cloud. Creates the cloud providers specific load balancer (ELB, NLB)
  So on Amazon it creates a ELB that points to your service on your cluster.
* ExternalName Create a CNAME dns record to a external domain.

[For more information about Services](https://kubernetes.io/docs/user-guide/services/)

Guide goes through some interesting concepts which include:

* Virtual hosts - Routing multiple domains to the same back-end service via Ingress
* Path rewrites - Lets say we have a `/new/get api` path, but the api does not support it. It does support `/get/new` we now need to rewrite the path to that. We can rewrite with an annotation: `ingress.kubernetes.io/rewrite-target: /new/get`
* Sticky sessions - nginx-ingress-controller can handle sticky sessions as it bypass the service level and route directly the pods. e.g. ConfigMap containing `enable-sticky-sessions: "true"`
* Proxy protocol - By default if you deploy the nginx-ingress-controller on AWS behind an ELB, it will not pass along the hostname unless you add the following ConfigMap data item: `use-proxy-protocol: "true"` AND on the Nginx Service yaml specification add the following annotation: `service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'`
* Custom Nginx configuration - Grab the `nginx.tmpl` from nginx-ingress-controller Github repo and edit as required. Create a ConfigMap from it `kubectl create configmap nginx-template --from-file=nginx.tmpl=./nginx.tmpl` and then reference it as a volume/volumeMounts


## Lessons learnt deploying to Production
[Good guide on running in Production](http://danielfm.me/posts/painless-nginx-ingress.html)

## Kubernetes and Prometheus
[Kubernetes monitoring with Prometheus](https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13)
[Prometheus Github](https://github.com/prometheus/prometheus)