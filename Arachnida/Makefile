VENV := .venv
.PHONY: spider scorpion
spider: $(VENV)
	@. $(VENV)/bin/activate && python3 spider.py $(FLAGS) $(URL)
scorpion: $(VENV)
	@. $(VENV)/bin/activate && python3 scorpion.py $(FLAGS) $(URL)
$(VENV):
	@virtualenv $(VENV) && . $(VENV)/bin/activate && pip install -Ur requirements.txt
