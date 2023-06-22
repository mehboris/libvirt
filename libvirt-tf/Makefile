.PHONY: all

.destroy_debian_internal:
    @terraform destroy -target=libvirt_domain.debian11 -auto-approve
	@terraform destroy  -target=libvirt_cloudinit_disk.commoninit-internal -auto-approve
    @terraform destroy  -target=libvirt_volume.debian-internal-qcow2 -auto-approve