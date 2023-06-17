## PREREQUISITES

### Create GKE Cluster

### Install Crossplane
helm repo add \
    crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
    crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace

### Install Schema Hero
HELM_EXPERIMENTAL_OCI=1 helm upgrade -i --wait --create-namespace -n schemahero schemahero oci://ghcr.io/schemahero/helm/schemahero

### Install Crossplane Provider AWS
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: upbound-provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.27.0
EOF

### Replace dummy values in aws-credentials.text with IAM which has correct RDS permissions

### Create a Kubernetes secret with the AWS credentials
kubectl create secret \
    generic aws-secret \
    -n crossplane-system \
    --from-file=creds=./aws-credentials.txt

### Create a ProviderConfig for AWS
cat <<EOF | kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-secret
      key: creds
EOF

### Apply the YAMLs for the Composite Resources
kubectl apply -f packages



## TALK

# CL: What do you need to develop your application?
# DD: I need to bring up all the services that my application depends on. That would be an S3 bucket, an SQS queue, a dynamo DB, a go server for batch processing, a fastAPI server, and a nodeJS frontend
# CL: Whoa. That's a lot.  How do you bring up all those things?
# DD: I would use the AWS console to create the S3 bucket, then there's an option somewhere there for SQS, and... I don't know :cry: Is complicated and I don't have AWS knowledge and don't want to depend on you each time. I would rather have a simple way to bring up the databases.
# CL: Argh..that's too much work. No way that you can figure all that on your own. There's a better way

kubectl create namespace dev

kubectl --namespace dev apply --filename claim.yaml

kubectl --namespace dev get tacoshop-database

# CL: What else do you need?
# DD: I need to be able to access the services

kubectl --namespace dev get secrets

kubectl get queues.sqs.aws.upbound.io

# Open AWS and show that the SQS queue was created as an example

# CL: What else do you need?
# DD: I need all those services I told you about up and running

okteto context use
okteto up --namespace dev
