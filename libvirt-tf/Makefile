.PHONY: all

destroy_debian_internal:
	@terraform destroy -target=libvirt_domain.debian11-internal -auto-approve
	@terraform destroy  -target=libvirt_cloudinit_disk.commoninit-internal -auto-approve
	@terraform destroy  -target=
	@terraform destroy  -target=libvirt_volume.debian-internal-qcow2 -auto-approve

stop_debian_internal:
	@terraform destroy -target=libvirt_domain.debian11-internal -auto-approve
	
destroy_debian:
	@terraform destroy -target=libvirt_domain.debian11 -auto-approve
	@terraform destroy  -target=libvirt_cloudinit_disk.commoninit1 -auto-approve
	@terraform destroy  -target=libvirt_volume.debian-qcow2 -auto-approve

stop_debian:
	@terraform destroy -target=libvirt_domain.debian11 -auto-approve

init:
	@terraform init

apply:
	@terraform apply -target=libvirt_pool.default2 -auto-approve
	@terraform apply -target=module.debian2 -auto-approve
	@terraform apply -target=libvirt_domain.debian11 -auto-approve
	@terraform apply -auto-approve


start_debian:
	@terraform apply -target=libvirt_domain.debian11 -auto-approve

start_debian_internal:
	@terraform apply -target=libvirt_domain.debian11-internal -auto-approve

