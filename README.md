
Docker image with [Hashicorp Terraform](https://www.terraform.io) + [Hashicorp Packer](https://www.packer.io) + [AWS CLI](https://aws.amazon.com/cli/) + [checkov](https://github.com/bridgecrewio/checkov) + Goodies

##### Github [https://github.com/marcosmachado81/docker-terraform-packer](https://github.com/marcosmachado81/docker-terraform-packer) forked from [https://github.com/thatarchguy/docker-terraform-packer](https://github.com/thatarchguy/docker-terraform-packer)

### Packages
    - ca-certificates
    - update-ca-certificates
    - curl
    - unzip
    - bash
    - python3
    - py-pip
    - openssh
    - git
    - make
    - tzdata
    - awscli (via PIP)  
    - jq
    - checkov (via PIP)

## INFO
- Workdir is set to /opt/workspace
- Github: [https://github.com/marcosmachado81/docker-terraform-packer](https://github.com/marcosmachado81/docker-terraform-packer)

## Usage
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
   		marcosmachado81/terraform-packer \
   		terraform [--version] [--help] <command> [args]
```

## Setting timezone
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
        -e TZ=Australia/Sydney \
   		marcosmachado81/docker-terraform-packer \
   		terraform [--version] [--help] <command> [args]
```


## Example
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
   		marcosmachado81/docker-terraform-packer \
   		terraform $1 -var-file variables.tfvars \
   		-var aws_access_key=${aws_access_key_id} \
   		-var aws_secret_key=${aws_secret_access_key}
```

## gitlab-ci.yml Example
Check all parameters to substitute for yours.
```yml
default:
  image: marcosmachado/docker-terraform-packer
  before_script:
    - terraform init
  cache:
    paths:
      - .terraform
      - tf.plan
      - tf.json

stages:
  - packer_flush
  - packer_build
  - terraform_plan
  - chekov_validation
  - terraform_apply

variables:
  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
  AWS_REGION: $AWS_REGION
  AWS_DEFAULT_REGION: $AWS_REGION
  TF_VAR_git_revision: ${CI_COMMIT_SHORT_SHA}

packer-flush:
  stage: packer_flush
  script:
    - export IMAGE_ID=$(aws ec2 describe-images --filter "Name=tag:Name,Values=my-ami-name" --query Images[*].ImageId --out text)
    - export SNAP_ID=$(aws ec2 describe-snapshots --filter "Name=tag:Name,Values=my-ami-name" --query Snapshots[*].{ID:SnapshotId} --out text)
    - if [ -z $IMAGE_ID ]; then echo "Ok" ; else aws ec2 deregister-image --image-id $IMAGE_ID && aws ec2 delete-snapshot --snapshot-id $SNAP_ID ; fi
  allow_failure: false
  only:
    changes:
    - packer.json
    - ./packer_provisioners/scripts/*
    - .gitlab-ci.yml

packer-build:
  stage: packer_build
  script:
    - echo "Packer Stage"
    - packer build packer.json
  allow_failure: false
  only:
    changes:
    - packer.json
    - ./packer_provisioners/scripts/*
    - .gitlab-ci.yml

terraform-plan:
  stage: terraform_plan
  script:
    - echo "Plan Terraform"
    - terraform plan -out tf.plan
    - terraform show -json tf.plan > tf.json
  allow_failure: false
  only:
    changes:
    - "*.{tf}"
    - "*.{tmpl}"
    - .gitlab-ci.yml

chekov-validation:
  stage: chekov_validation
  script:
    - echo "Check Security for terraform"
    - checkov -f tf.json
  allow_failure: false
  only:
    changes:
    - "*.{tf}"
    - "*.{tmpl}"
    - .gitlab-ci.yml

terraform-apply:
  stage: terraform_apply
  script:
    - echo "Apply Terraform"
    - terraform apply tf.plan
  allow_failure: false
  only:
    changes:
    - "*.{tf}"
    - "*.{tmpl}"
    - .gitlab-ci.yml
```

## Makefile example
```makefile
# VARS
TF_IMAGE?=marcosmachado81/docker-terraform-packer:latest
VARS_FILE?=variables.tfvars

# TF
tf-plan:
	$(call terraform, plan)
.PHONY: tf-plan

tf-apply:
	$(call terraform, apply)
.PHONY: tf-apply

tf-destroy:
	$(call terraform, destroy)
.PHONY: tf-destroy

tf-refresh:
	$(call terraform, refresh)
.PHONY: tf-refresh

tf-show:
	$(call terraform, show)
.PHONY: tf-show

tf-shell:
	@docker run --rm -it -v $(shell pwd):/opt/workspace \
    		$(TF_IMAGE)\
    		bash
.PHONY: tf-shell

tf-state-list:
	$(call terraform, state list)
.PHONY: tf-show

# DOCKER
tf-image-update:
	docker pull $(TF_IMAGE)
.PHONY: tf-image-update

# ROUTINES
define terraform
	@docker run --rm -v $(shell pwd):/opt/workspace \
		$(TF_IMAGE)\
		terraform $1 -var-file $(VARS_FILE) \
		-var aws_access_key=${aws_access_key_id} \
		-var aws_secret_key=${aws_secret_access_key}
endef

```
