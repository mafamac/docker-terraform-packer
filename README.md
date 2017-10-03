# thatarchguy/terraform-packer

Docker image with [Hashicorp Terraform](https://www.terraform.io) + [Hashicorp Packer](https://www.packer.io) + [AWS CLI](https://aws.amazon.com/cli/) + Goodies

##### Github [https://github.com/thatarchguy/docker-terraform-packer](https://github.com/thatarchguy/docker-terraform-packer)

### Packages
    - ca-certificates
    - update-ca-certificates
    - curl
    - unzip
    - bash
    - python
    - py-pip
    - openssh
    - git
    - make
    - tzdata
    - awscli (via PIP)  
    - jq

## INFO
- Workdir is set to /opt/workspace
- Github: [https://github.com/thatarchguy/docker-terraform-packer](https://github.com/thatarchguy/docker-terraform-packer)
- [Integration](#) with [Concourse CI](http://concourse.ci/)

## Usage
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
   		thatarchguy/terraform-packer \
   		terraform [--version] [--help] <command> [args]
```

## Setting timezone
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
        -e TZ=Australia/Sydney \
   		thatarchguy/terraform-packer \
   		terraform [--version] [--help] <command> [args]
```


## Example
```bash
$> docker run --rm -v $(pwd):/opt/workspace \
   		thatarchguy/terraform-packer \
   		terraform $1 -var-file variables.tfvars \
   		-var aws_access_key=${aws_access_key_id} \
   		-var aws_secret_key=${aws_secret_access_key}
```

## Makefile example
```makefile
# VARS
TF_IMAGE?=thatarchguy/terraform-packer:latest
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

### [Check the Concourse CI Pipeline used to build this image](https://github.com/marcelocorreia/docker-terraform/blob/master/pipeline.yml)

#### Concourse Build Configuration Example

```yaml
platform: linux

image_resource:
  type: docker-image
  source:
    repository: thatarchguy/terraform-packer
    tag: 'latest'

inputs:
- name: terraform-repo

run:
  path: terraform
  args:
  - plan
  - -var-file
  - variables.tfvars
```
