NAME := stockholm
VERSION := 0.42
DC := docker compose
.PHONY: all up down start stop logs ps me cry uncry test silent ​
all:
	$(info ​ $(NAME) - $(VERSION) ​)
	@echo -n "echo ​"
	$(MAKE) ​
up:
	$(DC) $@ --build -d
down start stop logs ps:
	$(DC) $@
test: 
	$(DC) exec quarantine /run/secrets/stockholm
silent cry:
	$(DC) exec quarantine /run/secrets/stockholm -s
uncry:
	$(DC) exec quarantine /run/secrets/stockholm -r /private.pem
no:
	$(DC) exec quarantine /run/secrets/stockholm -r /private.pem -s
me: |up
	echo "​" >/dev/null
​::
	$(MAKE) me cry
	@echo -n ​	$(info ​ - Thank you for using $(NAME) - $(VERSION) for your file encryption services. ​ )
	$(warning ​ This program is made purely for educational purposes. ​ )
	@echo -n ​  
	@2>/dev/null clear;cat flash.file|base64 -d
