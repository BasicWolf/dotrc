EMACSFLAGS=-Q --batch --no-site-file 
EMACS=emacs
LIBDIR=lib

all: compile

compile:
	$(EMACS) $(EMACSFLAGS) --eval '(byte-recompile-directory "$(LIBDIR)" 0 t)'
	$(EMACS) $(EMACSFLAGS) --eval '(byte-compile-file "init.el")'


clean: 
	rm -r init.elc $(LIBDIR)/*.elc

.PHONY: clean
