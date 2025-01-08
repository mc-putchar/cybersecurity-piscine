VENV := .venv

.PHONY: install run clean re
install: $(VENV)
	@echo "Installed ft_otp and ready to use"
run: $(VENV)
	@. $(VENV)/bin/activate && ft_otp --gui
clean:
	@rm -fr $(VENV) key.hex ft_otp.key
re: clean run

$(VENV):
	$(info Preparing virtual environment)
	@python3 -m venv $(VENV) && . $(VENV)/bin/activate && pip install -e .
