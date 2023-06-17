export DOCKER_DEFAULT_PLATFORM=linux/amd64

docker build -t ramiro/crossplane-dev-env-demo-check:latest app/check
docker build -t ramiro/crossplane-dev-env-demo-kitchen:latest app/kitchen
docker build -t ramiro/crossplane-dev-env-demo-kitchen-dev:latest --target dev app/kitchen
docker build -t ramiro/crossplane-dev-env-demo-menu:latest app/menu


docker push ramiro/crossplane-dev-env-demo-check:latest
docker push ramiro/crossplane-dev-env-demo-menu:latest
docker push ramiro/crossplane-dev-env-demo-kitchen:latest
docker push ramiro/crossplane-dev-env-demo-kitchen-dev:latest