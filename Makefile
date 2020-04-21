mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(realpath -L --relative-base $(dir $(mkfile_path)))

init:
	terraform init

console destroy graph plan output providers show: init
	export AWS_DEFAULT_REGION="eu-west-1"
	export AWS_SHARED_CREDENTIALS_FILE="${current_dir}/private/accessKeys.csv"
	terraform $@ \
		-var-file="${current_dir}/vars/global.tfvars" \
		-var-file="${current_dir}/vars/eu-west-1.tfvars"

get fmt validate version:
	terraform $@
