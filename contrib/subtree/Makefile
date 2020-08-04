# The default target of this Makefile is...
all::

SCRIPT_SH = git-subtree.sh
MAN1_TXT = git-subtree.txt
GIT_ROOT_DIR = ../..
GIT_DOC_DIR = $(GIT_ROOT_DIR)/Documentation
HERE = contrib/subtree

SCRIPT_SH_FULL = $(patsubst %,$(HERE)/%,$(SCRIPT_SH))
MAN1_TXT_FULL = $(patsubst %,../$(HERE)/%,$(MAN1_TXT))
DOC_HTML_FULL = $(patsubst %.txt,%.html,$(MAN1_TXT_FULL))

SCRIPT_GEN_EXTRA = -C $(GIT_ROOT_DIR) SCRIPT_SH="$(SCRIPT_SH_FULL)"
DOC_GEN_EXTRA = -C $(GIT_DOC_DIR) MAN1_TXT="$(MAN1_TXT_FULL)" \
		MAN_FILTER="$(MAN1_TXT_FULL)" \
		HTML_FILTER="$(DOC_HTML_FULL)"

RM ?= rm -f

GIT_SUBTREE_TEST := ../../git-subtree

all:: build

build:
	$(MAKE) $(SCRIPT_GEN_EXTRA) build-sh-script

doc: man html

man:
	$(MAKE) $(DOC_GEN_EXTRA) man

html:
	$(MAKE) $(DOC_GEN_EXTRA) html

install: build
	$(MAKE) $(SCRIPT_GEN_EXTRA) install-sh-script

install-doc: install-man install-html

install-man:
	$(MAKE) $(DOC_GEN_EXTRA) install-man

install-html:
	$(MAKE) $(DOC_GEN_EXTRA) install-html

$(GIT_SUBTREE_TEST): $(SCRIPT_SH)
	cp $< $@

test: $(GIT_SUBTREE_TEST)
	$(MAKE) -C ../../t/ T=t7900-subtree.sh test

clean:
	$(MAKE) $(SCRIPT_GEN_EXTRA) clean-sh-script
	$(RM) $(GIT_SUBTREE_TEST)
	$(RM) *.xml *.html *.1
