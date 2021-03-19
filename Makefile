include terraform.mk

REPOSITORY=docker-terraform-packer
CONTAINER=terraform
NAMESPACE=marcosmachado
TF_VERSION=$(terraform -v | grep -P -o "\d+\.\d+\.\d+")
PK_VERSION=$(packer-io -v)

update-version:
	sed -i "s/ARG tf_version=\".*\"/ARG tf_version=\"$TF_VERSION\"/" Dockerfile
	sed -i "s/ARG pk_version=\".*\"/ARG pk_version=\"$PK_VERSION\"/" Dockerfile

build:
	docker build -t $(NAMESPACE)/$(CONTAINER):latest .
.PHONY: build
