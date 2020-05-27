# K8s-logging PoC

## Usage

### Build Docker image

```
docker build -f rails-app/Dockerfile -t rails-app:latest ./rails-app
docker build -f fluentd/Dockerfile -t fluentd:latest ./fluentd
```

### Run K8s apps

```
kubectl apply -f elasticsearch.yml
kubectl apply -f kibana.yml
kubectl apply -f grafana.yml
kubectl apply -f app.yml
kubectl apply -f fluentd.yml
kubectl apply -f cerebro.yml
```

### Prepare Port fowarding

```
kubectl port-forward rails-xxxxxx 8080
kubectl port-forward grafana-xxxxxx 3000
kubectl port-forward kibana-xxxxxx 5601
kubectl port-forward cerebro-xxxxxx 9000
```

### Ingest data to ES

#### Rails General logs

```
while true; do curl localhost:8080/hello/hi; sleep 1; curl localhost:8080/hello/hello; sleep 2; done
```

#### Rails Error logs

```
while true; do curl localhost:8080/hello/error; sleep 10; done
```

### Using AES

If you want to use AES as an Elasticsearch backend to store Rails logs, change `FLUENT_ELASTICSEARCH_HOST` and run `kubectl apply -f fluentd-for-es-service.yml` instead of `kubectl apply -f fluentd.yml`

## Memo

### Access policy of AES

If your AES domain name is `taka-test-es`, use the following access policy with JSON Format.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:ap-northeast-1:214219211678:domain/taka-test-es/*"
    }
  ]
}
```

### Port forwarding to AES

To access AES running in development VPC on AWS dev account, run a basion EC2 (e.g. taka-test-001). Then, use portforwarding via the bastion host using `sshuttle`.

```
sshuttle -r taka-test-001.example.com 192.168.0.0/8  --dns
```

### K8s logging

* Use a node level logging agent
  *  https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-node-logging-agent
     - Commonly, the logging agent is a container that has access to a directory with log files from all of the application containers on that node.
     - it’s common to implement it as either a DaemonSet replica
     - Using a node-level logging agent is the most common and encouraged approach for a Kubernetes cluster,
     - **node-level logging only works for applications’ standard output and standard error.**
       - Interface for developers
     - The logic behind redirecting logs is minimal, so it’s hardly a significant overhead. Additionally, because stdout and stderr are handled by the kubelet, you can use built-in tools like kubectl logs.

### How Fluentd captures logs?

* via tail input plugin: https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/docker-image/v1.10/debian-elasticsearch7/conf/kubernetes.conf#L10-L22
  - parse type json: https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/docker-image/v1.10/debian-elasticsearch7/conf/kubernetes.conf#L19
* send ES with https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/docker-image/v1.10/debian-elasticsearch7/conf/fluent.conf#L10-L46

### Interface for developers

* STDOUT and STDERR are the interfaces for K8s logging
  - Ref: https://12factor.net/logs

## Q

* Should we write logs to disk and read from logging agent?
  - Pros: File IO is Synchronous operation
  - Cons: Disk size management is necessary
