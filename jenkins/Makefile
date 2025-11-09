SHELL := /bin/bash # Use bash syntax
ARG := $(word 2, $(MAKECMDGOALS) )

UTILS_DIR=/home/dadou/Nextcloud/Didier/python/dadou_utils_ros

SERVER ?= jenkins
PROJECT ?= robot
PROJECT_DIR ?= /home/dadou/Nextcloud/Didier/python/dadou_$(PROJECT)_ros

LOCAL_TEST_LOG=/logs/$(PROJECT)-test.log

s:
	ssh $(SERVER)

i:
	cmd=(ansible-playbook $(UTILS_DIR)/ansible/install-jenkins.yml -i $(UTILS_DIR)/ansible/hosts -e target_group=$(PROJECT)); \
	if [ -n "$(JENKINS_ADMIN_PASSWORD_FILE)" ]; then \
		cmd+=(-e jenkins_admin_manage=true -e jenkins_admin_password_source_file="$(JENKINS_ADMIN_PASSWORD_FILE)"); \
	elif [ -n "$(JENKINS_ADMIN_PASSWORD)" ]; then \
		cmd+=(-e jenkins_admin_manage=true -e jenkins_admin_password="$(JENKINS_ADMIN_PASSWORD)"); \
	fi; \
	"$${cmd[@]}"

it:
	ansible-playbook $(UTILS_DIR)/ansible/install-test-pios.yml -vv -i $(UTILS_DIR)/ansible/hosts -e target_group=$(SERVER);

dt:
	ansible-playbook $(UTILS_DIR)/ansible/deploy-pios-lite.yml -vv -i $(UTILS_DIR)/ansible/hosts -e target_group=$(SERVER);