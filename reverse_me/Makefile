NAME := patch_me_im_famous

TARBALL := binary.tgz
BINDIR := binary
PATCHDIR := patched
PATCH := patch.sh
SRCS := level1/source.c
SRCS += level2/source.c
SRCS += level3/source.c
BINS := $(SRCS:%source.c=%a.out)

.PHONY: all build patch verify verify-patch clean re
all: build verify patch verify-patch
build: $(BINS)
patch: $(PATCH) $(BINDIR)
	@chmod +x $(PATCH) && ./$(PATCH)
verify: $(BINS)
	-cat ./level1/password | level1/a.out
	-cat ./level2/password | level2/a.out
	-cat ./level3/password | level3/a.out
verify-patch: $(PATCHDIR)
	-echo "" | ./$(PATCHDIR)/level1
	-echo "" | ./$(PATCHDIR)/level2
	-echo "" | ./$(PATCHDIR)/level3
	-python3 -c 'print("*042*" * 1024)' | ./$(PATCHDIR)/level1
	-python3 -c 'print("*042*" * 1024)' | ./$(PATCHDIR)/level2
	-python3 -c 'print("*042*" * 1024)' | ./$(PATCHDIR)/level3
clean:
	@-rm -r $(PATCHDIR) $(BINS)
re: clean all
$(BINDIR): $(TARBALL)
	@tar xf $(TARBALL)
$(BINS):
$(BINS): %/a.out: %/source.c
	$(CC) $(CFLAGS) -o $@ $^ && chmod +x $@
