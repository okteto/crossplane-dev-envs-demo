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
# DD: I need to bring up all the serivces that my application depends on. That would be a Postgres database and the go server in this case.

# CL: How do you bring up the Postgres database?
# DD: I would use the AWS console to create a RDS instance. But that is complicated and I don't have AWS knowledge and don't want to depend on you each time. I would rather have a simple way to bring up the database.

kubectl --namespace dev apply \
    --filename claim.yaml

kubectl --namespace dev \
    get sqlclaims

# CL: What else do you need?
# DD: I need to be able to access that database server

kubectl --namespace dev \
    get secrets

./examples/sql/schemahero-secret.sh dev

kubectl get databases.postgresql.sql.crossplane.io

# Open pgAdmin and show that the DB was created

# CL: What else do you need?
# DD: I need my application up and running with the table created

okteto context use

okteto up --namespace dev
