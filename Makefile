VAGRANT_IP := $(shell cat VAGRANT_IP)


.PHONY: up prepare cook
all:: prepare cook


base:
	if [ -z `vagrant box list | ruby -ne 'puts 1 if $$_.chop == "base"'` ]; then \
		vagrant box add base http://ergonlogic.com/files/boxes/debian-current.box; \
	fi;

up: base
	vagrant up

prepare: up
	knife solo prepare vagrant@${VAGRANT_IP}

cook: up
	knife solo cook vagrant@${VAGRANT_IP}
