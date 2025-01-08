PYVENV := python3 -m venv
#PYVENV := virtualenv
VENV := .venv
.PHONY: spider scorpion
all: $(VENV)
spider: $(VENV)
	@. $(VENV)/bin/activate && python3 spider.py $(FLAGS) $(URL)
scorpion: $(VENV)
	@. $(VENV)/bin/activate && python3 scorpion.py $(FLAGS) $(URL)
$(VENV):
	$(info Preparing virtual environment)
	@$(PYVENV) $(VENV) && . $(VENV)/bin/activate && pip install -Ur requirements.txt
	@echo "Arachnids ready to deploy"
