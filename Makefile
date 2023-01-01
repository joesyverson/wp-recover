SHELL := /bin/bash
.PHONY: help

VERSION='current'

help:
	@echo ""
	@echo "help                      Print this menu"
	@echo "ansible-backup            Back up with Ansible if you have it installed"
	@echo "containers-down           Stop and destroy those containers"
	@echo "containers-stage VERSION  Wipe date from containers, replace with your selected VERSION"
	@echo "containers-stop           Containers stop!"
	@echo "containers-up             Containers start!"
	@echo "db-update-links           Find and replace all links with those suitable for local development"
	@echo "init                      Make some ignored directories required for this implementation"
	@echo "server-backup             Make a backup using SSH"
	@echo "server-shell              Log into the server's shell"

ansible-backup:
	@./Make.sh _ansible_backup

containers-down:
	@./Make.sh _containers_down

containers-stage:
	@./Make.sh _containers_stage $(VERSION)

containers-stop:
	@./Make.sh _containers_stop

containers-up:
	@./Make.sh _containers_up

db-update-links:
	@./Make.sh _db_update_links

init:
	@./Make.sh _init

server-backup:
	@./Make.sh _server_backup

server-shell:
	@./Make.sh _server_shell
