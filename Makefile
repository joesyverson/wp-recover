SHELL := /bin/bash
.PHONY: help

VERSION='current'

help:
	@echo ""
	@echo "help"

containers-down:
	@./Make.sh _containers_down

containers-stop:
	@./Make.sh _containers_stop

containers-up:
	@./Make.sh _containers_up

server-backup:
	@./Make.sh _server_backup

server-shell:
	@./Make.sh _server_shell

stage:
	@./Make.sh _stage $(VERSION)