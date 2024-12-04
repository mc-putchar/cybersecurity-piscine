NAME := ft_onion

DC := docker compose
SRC := compose.yaml

HOSTNAME := hostname
GITNAME := gitname
ENVFILE := .env
SSH := .ssh
AUTH_KEYS := $(SSH)/authorized_keys
TOR_CLIENT_PORT := 9150

# Colors
COLOUR_END := \033[0m
COLOUR_GREEN := \033[32m
COLOUR_RED := \033[31m
COLOUR_MAG := \033[35m
COLOUR_MAGB := \033[1;35m
COLOUR_CYN := \033[36m
COLOUR_CYNB := \033[1;36m

.PHONY: help up down start stop re logs ps clean name curl admin

help: # Display this helpful message
	@awk 'BEGIN { \
	FS = ":.*#"; printf "Usage:\n\t$(COLOUR_CYNB)make $(COLOUR_MAGB)<target> \
	$(COLOUR_END)\n\nTargets:\n"; } \
	/^[a-zA-Z_0-9-]+:.*?#/ { \
	printf "$(COLOUR_MAGB)%-16s$(COLOUR_CYN)%s$(COLOUR_END)\n", $$1, $$2 } ' \
	Makefile

up: $(ENVFILE) $(AUTH_KEYS) # Up the tor
	@$(DC) -f $(SRC) $@ --build -d
down: # Chop that onion down
	@$(DC) -f $(SRC) $@
start: # Start containers
	@$(DC) -f $(SRC) $@
stop: # Stop the containers, please
	@$(DC) -f $(SRC) $@
re: down # Re-create and run containers
	@$(DC) -f $(SRC) up --build --force-recreate -d
logs: # Tail the logs 
	@$(DC) -f $(SRC) logs --tail=100 -f
ps: # Show running containers
	@$(DC) -f $(SRC) ps
clean: down # Clean docker system
	docker system prune
name: $(HOSTNAME) $(GITNAME) # Display .onion hostname
	@echo "Hostname: `cat $(HOSTNAME)`"
	@echo "Gitea Hostname: `cat $(GITNAME)`"
$(HOSTNAME): up
	@$(DC) -f $(SRC) exec tor cat /var/lib/tor/ft_onion/hostname >$(HOSTNAME)
$(GITNAME): up
	@$(DC) -f $(SRC) exec tor cat /var/lib/tor/gitea/hostname >$(GITNAME)
curl: $(HOSTNAME) # Curl the website
	curl --socks5-hostname 127.0.0.1:$(TOR_CLIENT_PORT) `cat $(HOSTNAME)`
admin: $(HOSTNAME) # Connect to server via SSH
	ssh -p4242 -i $(SSH)/id_ed25519 -o ProxyCommand='nc -x 127.0.0.1:$(TOR_CLIENT_PORT) %h %p' onion@`cat $(HOSTNAME)`
$(AUTH_KEYS): $(SSH)
	ssh-keygen -t ed25519 -f $(SSH)/id_ed25519
	cp $(SSH)/id_ed25519.pub $(SSH)/authorized_keys
$(SSH):
	@mkdir -p $@
$(ENVFILE):
	@echo "POSTGRES_USER=gitea" > $(ENVFILE)
	@echo -n "POSTGRES_PASSWORD=" >> $(ENVFILE)
	@openssl rand -base64 42 | tr -d '=+/' | cut -c1-24 >> $(ENVFILE)
