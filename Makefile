install:
	cp dist/etc/initramfs-tools/hooks/prepare_auto_unlock_deps /etc/initramfs-tools/hooks/prepare_auto_unlock_deps && \
	cp dist/etc/initramfs-tools/scripts/init-premount/prepare_cryptroot /etc/initramfs-tools/scripts/init-premount/prepare_cryptroot && \
	cp dist/usr/local/etc/auto_unlock.conf /usr/local/etc/auto_unlock.conf && \
	cp dist/usr/local/bin/auto_unlock_install_key.sh /usr/local/bin/auto_unlock_install_key.sh && \
	chmod +x /usr/local/bin/auto_unlock_install_key.sh &&
	update-initramfs -k `uname -r` -u

set-keys:
	/usr/local/bin/auto_unlock_install_key.sh

install-deps:
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt install build-essential module-assistant
	sudo m-a prepare
	sudo adduser cucu vboxsf