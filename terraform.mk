plan:
	$(call terraform, plan)
.PHONY: plan

apply:
	$(call terraform, apply)
.PHONY: apply

destroy:
	$(call terraform, destroy)
.PHONY: destroy

refresh:
	$(call terraform, refresh)
.PHONY: refresh

show:
	docker run --rm -v $(shell pwd):/opt/workspace \
    	thatarchguy/terraform-packer \
    	terraform show
.PHONY: show

define terraform
	@docker run --rm -v $(shell pwd):/opt/workspace \
		thatarchguy/terraform-packer \
		terraform $1 -var-file variables.tfvars \
		-var aws_access_key=${aws_access_key_id} \
		-var aws_secret_key=${aws_secret_access_key}
endef
