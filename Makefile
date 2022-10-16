SHELL := /bin/bash
.PHONY: help

VERSION='current'

help:
	@echo ""
	@echo "help"

containers-down:
	@./Make.sh _containers_down

containers-restore:
	@./Make.sh _containers_restore

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
