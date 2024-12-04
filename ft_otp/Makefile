VENV := .venv

.PHONY: run clean re
run: $(VENV)
	@. $(VENV)/bin/activate && ft_otp --gui
clean:
	@rm -fr $(VENV) key.hex ft_otp.key
re: clean run

$(VENV):
	@virtualenv $(VENV) && . $(VENV)/bin/activate && pip install -e .
