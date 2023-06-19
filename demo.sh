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

# DD: I'm a developer at the world famous taco shop, and we recently migrated from a monolith to microservices. It used to be a monolith, and I knew now to bring every up, but it now that we are in Kubernetes, I'm confused. Can you help me?

# CL: OMG. I guess.  What do you need to develop your application?

# DD: I need to bring up all the cloud services that my application depends on. That would be an S3 bucket, an SQS queue. But I don't know how to get access to the AWS account. Do I just use my own? 

# CL: No! You need to the use your team's account. And make sure that you create them with the right tags, the right version, and in the right region! 

# DD: What? What is a region? Like the Tel Aviv AWS region? I have no idea what you're talking about. 

# CL: If only, but no. Okey, this is a lot. And you need this every single time?

# DD: Of course. How else do you want me to develop? I want to make sure that my code works!

# CL: Ok. We need to automate this. I don't want you opening 300 JIRA tickets every day.

# CL: You know what, I think crossplane is a the right tool for this!

# CL: Let me start by creating an abstraction for all your AWS needs

# CL: Shows compositions and composition definition

kubectl create namespace dev

# CL: Shows claim

# DD: So I only have to apply that one file right? 

kubectl --namespace dev apply --filename claim.yaml

# CL: Yes, and this will automatically create the infra for you, with all the necessary configurations, and following all our internal rules. That way no one gets in trouble.

kubectl --namespace dev get tacoshop-database

kubectl get queues.sqs.aws.upbound.io 
kubectl get buckets.s3.aws.upbound.io

# CL: Why are you still here? Do you need even more things?

# DD: Of course. I have the cloud resources but what about the three...million microservices that we use? I want to see my application up and running. And who do I get the services to talk to the cloud resources?

# CL: Wow, you really just want to focus on code right? I'm guessing you don't even know how to pronounce Kubernetes.

# DD: Do you mean Koober-nets?

# CL: Argh...never mind. Let's automate ourselves away from this problem once and for all. 

# CL: Take a look at this beautiful yaml file. It describes your entire development environment, from building the latest images, to deploying your microservices in Kubernetes, and finally, to developing directly in Kubernetes. This way, you don't need to run anything manually, and you don't need to be an expert on every single project in the CNCF landscape.

# DD: Landscape? Can I go there?

# CL: Stares... no. 

okteto up --namespace dev

