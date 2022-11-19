echo 'Deploying App on Kubernetes'
envsubst < k8s/captain-demir_chart/values-template.yaml > k8s/captain-demir_chart/values.yaml
sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/captain-demir_chart/Chart.yaml
AWS_REGION=$AWS_REGION helm repo add stable-captain-demir s3://captain-demir-helm-charts-web-microservices/stable/myapp/ || echo "repository name already exists"
AWS_REGION=$AWS_REGION helm repo update
helm package k8s/captain-demir_chart
AWS_REGION=$AWS_REGION helm s3 push captain-demir_chart-${BUILD_NUMBER}.tgz stable-captain-demir
envsubst < ansible/playbooks/qa-captain-demir-deploy-template >ansible/playbooks/qa-captain-demir-deploy.yaml
ansible-playbook -i ./ansible/inventory/qa_stack_dynamic_inventory_aws_ec2.yaml ./ansible/playbooks/qa-captain-demir-deploy.yaml