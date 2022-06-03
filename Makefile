ENV?=lab
STATE?=s3://tvld-k8s-gitops-kops-state
CLUSTER?=${ENV}.kind.tvld.tech

.PHONY: create
create:
	kustomize build ${ENV} | kops create --state=${STATE} -f -

.PHONY: replace
replace:
	kustomize build ${ENV} | kops replace --state=${STATE} -f -

.PHONY: update
update:
	kops update cluster --state=${STATE} --name ${CLUSTER} --yes

.PHONY: export
export:
	kops export kubeconfig ${CLUSTER} --state=${STATE} --admin

.PHONY: rolling-update
rolling-update:
	kops rolling-update cluster --state=${STATE} --force --yes

.PHONY: validate
validate:
	kops validate cluster ${CLUSTER} --wait 10m --state=${STATE}

.PHONY: delete
delete:
	kops delete cluster ${CLUSTER} --state=${STATE} --yes

##
## Specific target for k8s-gitops-kops
##

.PHONY: update-lab-ami
update-lab-ami:
	NEW_VERSION=$(shell aws ec2 describe-images --output text --owners amazon --filters "Name=architecture,Values=arm64" \
		"Name=root-device-type,Values=ebs" "Name=block-device-mapping.volume-type,Values=gp2" \
		"Name=name,Values=amzn2-ami-kernel-5.10-hvm-*" --query 'sort_by(Images, &CreationDate)[-1].ImageLocation' | cat); \
	mv lab/instance.image.patch.yaml lab/instance.image.patch.yaml.backup; \
	sed "s|image: .*|image: $$NEW_VERSION|" lab/instance.image.patch.yaml.backup > lab/instance.image.patch.yaml; \
	rm lab/instance.image.patch.yaml.backup;

.PHONY: copy-lab-to-prod-ami
copy-lab-to-prod-ami:
	cp lab/instance.image.patch.yaml prod/instance.image.patch.yaml
