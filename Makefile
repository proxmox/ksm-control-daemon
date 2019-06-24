PACKAGE=ksm-control-daemon

# also update debian/changelog
PKGVER=1.3
PKGREL=1

KSM_DEB=${PACKAGE}_${PKGVER}-${PKGREL}_all.deb

GITVERSION:=$(shell git rev-parse HEAD)

all: ${KSM_DEB}

${KSM_DEB} ksm: ksm-control-scripts.org/ksm.init
	rm -rf ksm-control-scripts
	rsync -a --exclude .git ksm-control-scripts.org/ ksm-control-scripts
	cp -a debian ksm-control-scripts
	echo "git clone git://git.proxmox.com/git/ksm-control-daemon.git\\ngit checkout ${GITVERSION}" > ksm-control-scripts/debian/SOURCE
	cd ksm-control-scripts; dpkg-buildpackage -b -us -uc
	lintian ${KSM_DEB} || true

.PHONY: download
download:
	rm -rf ksm-control-scripts.org ksm-control-scripts.org.tar.gz
	git clone git://gitorious.org/ksm-control-scripts/ksm-control-scripts.git ksm-control-scripts.org
	tar czf ksm-control-scripts.org.tar.gz ksm-control-scripts.org

ksm-control-scripts.org/ksm.init: ksm-control-scripts.org.tar.gz
	tar xzf ksm-control-scripts.org.tar.gz
	touch $@

.PHONY: upload
upload: ${KSM_DEB}
	tar cf - ${KSM_DEB} | ssh repoman@repo.proxmox.com -- upload --product pve --dist stretch

.PHONY: distclean
distclean: clean
	rm -rf ksm-control-scripts.org

.PHONY: clean
clean:
	rm -rf *~ ksm-control-scripts ${PACKAGE}_*

.PHONY: dinstall
dinstall: ${KSM_DEB}
	dpkg -i ${KSM_DEB}
