# really just some handy scripts...

KEXT=BrcmPatchRAM.kext
INJECT=BrcmBluetoothInjector.kext
DIST=RehabMan-BrcmPatchRAM
#INSTDIR=/TestExtensions
INSTDIR=/System/Library/Extensions
BUILDDIR=./Build/Products

ifeq ($(findstring 32,$(BITS)),32)
OPTIONS:=$(OPTIONS) -arch i386
endif

ifeq ($(findstring 64,$(BITS)),64)
OPTIONS:=$(OPTIONS) -arch x86_64
endif

OPTIONS:=$(OPTIONS)

.PHONY: all
all:
	xcodebuild build $(OPTIONS) -scheme "BrcmPatchRAM" -configuration Debug
	xcodebuild build $(OPTIONS) -scheme "BrcmPatchRAM" -configuration Release

.PHONY: clean
clean:
	xcodebuild clean $(OPTIONS) -scheme "BrcmPatchRAM" -configuration Debug
	xcodebuild clean $(OPTIONS) -scheme "BrcmPatchRAM" -configuration Release

.PHONY: update_kernelcache
update_kernelcache:
	sudo touch /System/Library/Extensions
	sudo kextcache -update-volume /

.PHONY: install_debug
install_debug:
	sudo cp -R $(BUILDDIR)/Debug/$(KEXT) $(INSTDIR)
	make update_kernelcache

.PHONY: install
install:
	sudo cp -R $(BUILDDIR)/Release/$(KEXT) $(INSTDIR)
	make update_kernelcache

.PHONY: install_inject
install_inject:
	sudo cp -R $(BUILDDIR)/Release/$(INJECT) $(INSTDIR)
	make update_kernelcache

.PHONY: distribute
distribute:
	if [ -e ./Distribute ]; then rm -r ./Distribute; fi
	mkdir ./Distribute
	#cp -R $(BUILDDIR)/Debug ./Distribute
	cp -R $(BUILDDIR)/Release ./Distribute
	find ./Distribute -path *.DS_Store -delete
	find ./Distribute -path *.dSYM -exec echo rm -r {} \; >/tmp/org.voodoo.rm.dsym.sh
	chmod +x /tmp/org.voodoo.rm.dsym.sh
	/tmp/org.voodoo.rm.dsym.sh
	rm /tmp/org.voodoo.rm.dsym.sh
	ditto -c -k --sequesterRsrc --zlibCompressionLevel 9 ./Distribute ./Archive.zip
	mv ./Archive.zip ./Distribute/`date +$(DIST)-%Y-%m%d.zip`
