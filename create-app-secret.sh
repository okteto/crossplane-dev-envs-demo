# TODO: replace this with a crossplane generated secret
# set AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY

namespace=${1:-"default"}

database=$(kubectl get tacoshop-database my-db -o=jsonpath='{.spec.resourceRef.name}')
bucket=$(kubectl get database $database -o=jsonpath='{.spec.resourceRefs[0].name}')
queue=$(kubectl get database $database -o=jsonpath='{.spec.resourceRefs[1].name}')

SQS_QUEUE_URL=$(kubectl get queues.sqs.aws.upbound.io $queue -o=jsonpath='{.metadata.annotations.crossplane\.io/external-name}')
SQS_QUEUE_NAME=$(kubectl get queues.sqs.aws.upbound.io $queue -o=jsonpath='{.spec.forProvider.name}')
AWS_REGION=$(kubectl get queues.sqs.aws.upbound.io $queue -o=jsonpath='{.spec.forProvider.region}')
S3_BUCKET_NAME=$(kubectl get buckets.s3.aws.upbound.io -o=jsonpath='{.items[0].metadata.annotations.crossplane\.io/external-name}')


kubectl create secret generic my-db-secret \
--save-config \
--dry-run=client \
--from-literal=QUEUE=$SQS_QUEUE_URL \
--from-literal=QUEUE_NAME=$SQS_QUEUE_NAME \
--from-literal=BUCKET=$S3_BUCKET_NAME \
--from-literal=AWS_REGION=$AWS_REGION \
--from-literal=AWS_DEFAULT_REGION=$AWS_REGION \
--from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
--from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
-o yaml | \
kubectl apply -n=$namespace -f -






