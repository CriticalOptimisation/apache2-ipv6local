PACKAGE_NAME := apache2-ipv6local
PACKAGE_VERSION := 1.0.0
DEB_FILE := $(PACKAGE_NAME)_$(PACKAGE_VERSION)_all.deb
DEBIAN=apache2-ipv6local/DEBIAN
DEB_META=$(DEBIAN)/control $(DEBIAN)/postinst $(DEBIAN)/prerm
DEB_SYSD=apache2-ipv6local/etc/systemd/system
DEB_SERV=$(DEB_SYSD)/update-ipv6local.service $(DEB_SYSD)/update-ipv6local.timer $(DEB_SYSD)/apache2.service.d/update-ipv6local.conf

all: $(DEB_FILE)

$(DEB_FILE): apache2-ipv6local/usr/bin/update-ipv6local.sh $(DEB_SERV) $(DEB_META)
	dpkg-deb --build $(PACKAGE_NAME)
	mv $(PACKAGE_NAME).deb $(DEB_FILE)
	sudo chown _apt:root $(DEB_FILE)

clean:
	rm -rf $(PACKAGE_NAME)
	rm -f $(DEB_FILE)

.PHONY: all clean

