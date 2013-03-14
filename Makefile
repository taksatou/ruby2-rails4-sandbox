VAGRANT_IP := $(shell cat VAGRANT_IP)


.PHONY:
all::

up:
	vagrant up

prepare: up
	knife solo prepare vagrant@${VAGRANT_IP}

cook: up
	knife solo cook vagrant@${VAGRANT_IP}

suspend:
	vagrant suspend
