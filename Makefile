SHELL := /bin/bash
.PHONY: help

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