TAG=3.14

clean:
	test -d linux && cd linux && rm -f .config
	test -d linux && cd linux git clean -df

all:
	test -d linux || git clone \
	https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
	cp config/config-$(TAG) linux/.config
	cd linux && git checkout master
	cd linux && git fetch
	cd linux && git rebase
	gpg --keyserver keys.gnupg.net --recv-key 00411886
	cd linux && git verify-tag v$(TAG)
	cd linux && git checkout v$(TAG)
	cd linux && make clean
	cd linux && make oldconfig
	cd linux && make -j6 zImage modules dtbs
	rm linux/deploy -rf
	mkdir -p linux/deploy/dtbs
	VERSION=$(cd linux && make kernelversion) && \
	cp linux/.config linux/deploy/config-$(VERSION)
	VERSION=$(cd linux && make kernelversion) && \
	cp linux/arch/arm/boot/zImage linux/deploy/$(VERSION).zImage
	cd linux && make modules_install INSTALL_MOD_PATH=deploy
	cd linux && make headers_install INSTALL_HDR_PATH=deploy/usr
	find linux/arch/arm/boot/dts/ -name *.dtb -exec cp {} linux/deploy/dtbs \;
	VERSION=$(cd linux && make kernelversion) && \
	cd linux/deploy && tar -czf $(VERSION)-dtbs.tar.gz dtbs
	VERSION=$(cd linux && make kernelversion) && \
	cd linux/deploy && tar -czf $(VERSION)-modules-firmware.tar.gz lib
	VERSION=$(cd linux && make kernelversion) && \
	cd linux/deploy && tar -czf $(VERSION)-headers.tar.gz usr
	VERSION=$(cd linux && make kernelversion) && \
	cp linux/.config linux/deploy/config-$(VERSION)
