# k8sapi-demo

The script demonstrates how to access the k8s API from Perl. Upon invocation, prints the list of deployments, images of each deployment, and the date deployment was updated.
Requires Kubernetes::REST Perl module.
 
# Usage:

```
k8squery.pl --namespace=<namespace> [--expand_conditions=0|1 ]
```

# Example

```
k8squery.pl --namespace='default'
Deployment name Last state change
nginx-deployment        2021-10-12T20:24:43Z
        - Container     Name            Image
                        nginx           nginx:1.14.2

k8squery.pl --namespace='default' --expand_conditions=1
Deployment name Last state change
nginx-deployment        2021-10-12T20:26:43Z
        - Condition     Message                                         Timestamp
                        ReplicaSet "nginx-deployment-66b6c48dd5" has su 2021-10-07T16:40:03Z
                        Deployment has minimum availability.            2021-10-12T20:26:43Z
        - Container     Name            Image
                        nginx           nginx:1.14.2
```
