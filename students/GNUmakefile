##############################################################################
.PHONEY: install
install:
	@ : # do nothing

##############################################################################
# $1: Source
# $2: Destination
define INSTALL_FILE
install: $(2)
$(2): $(1)
	mkdir -p $(dir $(2))
	install -m 0644 $(1) $(2)
endef

##############################################################################
$(eval $(call INSTALL_FILE,gconf.apps.gnome-screensaver.%gconf.xml,~/.gconf/apps/gnome-screensaver/%gconf.xml))
