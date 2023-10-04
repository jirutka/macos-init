PKGNAME             := macos-init
LAUNCHD_DAEMON_NAME := cz.jirutka.$(PKGNAME)

prefix              := $(or $(prefix),$(PREFIX),/usr/local)
bindir              := $(prefix)/bin
datadir             := $(prefix)/share
sysconfdir          := $(prefix)/etc
DATA_DIR            := $(datadir)/$(PKGNAME)
LAUNCHD_DAEMON_DIR  := /Library/LaunchDaemons

GIT                 := git
INSTALL             := install
SED                 := sed

MAKEFILE_PATH        = $(lastword $(MAKEFILE_LIST))

#: Print list of targets.
help:
	@printf '%s\n\n' 'List of targets:'
	@$(SED) -En '/^#:.*/{ N; s/^#: (.*)\n([A-Za-z0-9_-]+).*/\2 \1/p }' $(MAKEFILE_PATH) \
		| while read label desc; do printf '%-17s %s\n' "$$label" "$$desc"; done

#: Check shell scripts for syntax errors.
check:
	@rc=0; for f in share/utils.sh share/platforms/* share/scripts/*; do \
		if $(SHELL) -n $$f; then \
			printf "%-33s PASS\n" $$f; \
		else \
			rc=1; \
		fi; \
	done; \
	exit $$rc

#: Install files to ${DESTDIR}.
install:
	@$(INSTALL) -d $(DESTDIR)$(bindir)
	@$(INSTALL) -v -m 755 bin/macos-init $(DESTDIR)$(bindir)/macos-init
	@$(INSTALL) -d $(DESTDIR)$(sysconfdir)
	@$(INSTALL) -v -m 644 etc/macos-init.conf $(DESTDIR)$(sysconfdir)/macos-init.conf
	@$(INSTALL) -d $(DESTDIR)$(DATA_DIR)/platforms $(DESTDIR)$(DATA_DIR)/scripts
	@$(INSTALL) -v -m 644 share/utils.sh $(DESTDIR)$(DATA_DIR)/utils.sh
	@$(INSTALL) -v -m 755 share/platforms/* $(DESTDIR)$(DATA_DIR)/platforms/
	@$(INSTALL) -v -m 755 share/scripts/* $(DESTDIR)$(DATA_DIR)/scripts/
	@$(INSTALL) -d $(DESTDIR)$(LAUNCHD_DAEMON_DIR)
	@$(INSTALL) -v -m 644 LaunchDaemons/$(LAUNCHD_DAEMON_NAME).plist $(DESTDIR)$(LAUNCHD_DAEMON_DIR)/$(LAUNCHD_DAEMON_NAME).plist

#: Remove files previously installed to ${DESTDIR}.
uninstall:
	@rm -v "$(DESTDIR)$(bindir)/macos-init"
	@rm -v "$(DESTDIR)$(sysconfdir)/macos-init.conf"
	@rm -v "$(DESTDIR)$(LAUNCHD_DAEMON_DIR)/$(LAUNCHD_DAEMON_NAME).plist"
	@rm -rfv "$(DESTDIR)$(DATA_DIR)"

#: Update version in bin/macos-init, Formula/macos-init.rb and README.adoc to $VERSION.
bump-version:
	test -n "$(VERSION)"  # $$VERSION
	$(SED) -E -i "s/^(readonly VERSION=).*/\1'$(VERSION)'/" bin/macos-init
	$(SED) -E -i "s/^([[:space:]]*version )\".*/\1\"$(VERSION)\"/" Formula/macos-init.rb
	$(SED) -E -i "s/^(:version:).*/\1 $(VERSION)/" README.adoc

#: Bump version to $VERSION, create release commit and tag.
release: .check-git-clean | bump-version
	test -n "$(VERSION)"  # $$VERSION
	$(GIT) add .
	$(GIT) commit --allow-empty -m "Release version $(VERSION)"
	$(GIT) tag -s v$(VERSION) -m v$(VERSION)

.PHONY: help check install uninstall bump-version release


.check-git-clean:
	@test -z "$(shell $(GIT) status --porcelain)" \
		|| { echo 'You have uncommitted changes!' >&2; exit 1; }

.PHONY: .check-distro .check-git-clean
