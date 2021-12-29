STATE?=s3://k8s-gitops-kops-state
CLUSTER?=lab.lebiller.dev

create:
	kustomize build lab | kops create --state=${STATE} -f -

replace:
	kustomize build lab | kops replace --state=${STATE} -f -

update:
	kops update cluster --state=${STATE} --name ${CLUSTER} --yes

rolling-update:
	kops rolling-update cluster --state=${STATE} --force --yes

delete:
	kops delete cluster ${CLUSTER} --state=${STATE} --yes

export:
	kops export kubeconfig ${CLUSTER} --state=${STATE} --admin
