# default target builds 64-bit, build qm32 target for a 32-bit build

GROUPADD := $(shell command -v adduser 2> /dev/null || command -v groupadd 2> /dev/null)
USERADD := $(shell command -v addgroup 2> /dev/null || command -v useradd 2> /dev/null)

MAIN     := $(shell pwd)/
GPLSRC   := $(MAIN)gplsrc/
GPLDOTSRC := $(MAIN)gpl.src
GPLOBJ   := $(MAIN)gplobj/
GPLBIN   := $(MAIN)bin/

ifneq ($(wildcard /usr/lib/systemd/system/.),)
	SYSTEMDPATH := /usr/lib/systemd/system
else
	SYSTEMDPATH := /lib/systemd/system
endif

OSNAME   := $(shell uname -s)

COMP     := gcc

ifeq (Darwin,$(OSNAME))
	ARCH :=
	C_FLAGS  := -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH)
	L_FLAGS  := -lm -ldl
	INSTROOT := /opt/qmsys
	SONAME_OPT := -install_name
else
	L_FLAGS  := -Wl,--no-as-needed -lm -lcrypt -ldl -lcrypto
	INSTROOT := /usr/qmsys
	SONAME_OPT := -soname
endif

QMSRCS   := $(shell cat $(GPLDOTSRC))
QMTEMP   := $(addsuffix .o,$(QMSRCS))
QMOBJSD  := $(addprefix $(GPLOBJ),$(QMTEMP))
QMSYS   := $(shell cat /etc/passwd | grep qmsys)
QMUSERS := $(shell cat /etc/group | grep qmusers)

DEPDIR := ./deps/

SOURCES := $(filter-out gplsrc/qmclient.c, $(wildcard gplsrc/*.c))
OBJECTS = $(patsubst gplsrc/%.c, gplobj/%.o, $(SOURCES))

qm: ARCH :=
qm: C_FLAGS = -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH) -fPIE -fPIC -MMD -MF $(DEPDIR)/$*.d
qm: $(OBJECTS) $(GPLBIN)qmclilib.so $(GPLBIN)qmtic $(GPLBIN)qmfix $(GPLBIN)qmconv $(GPLBIN)qmidx $(GPLBIN)qmlnxd
	@echo "Linking qm."
	@$(COMP) $(ARCH) $(L_FLAGS) $(QMOBJSD) -o $(GPLBIN)qm

qm32: ARCH := -m32
qm32: C_FLAGS = -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH) -MMD -MF $(DEPDIR)/$*.d
qm32: $(OBJECTS) $(GPLBIN)qmclilib.so $(GPLBIN)qmtic $(GPLBIN)qmfix $(GPLBIN)qmconv $(GPLBIN)qmidx $(GPLBIN)qmlnxd
	@echo "Linking qm."
	@$(COMP) $(ARCH) $(L_FLAGS) $(QMOBJSD) -o $(GPLBIN)qm

$(GPLBIN)qmclilib.so: $(GPLOBJ)qmclilib.o
	$(COMP) -shared -Wl,$(SONAME_OPT),qmclilib.so -lc $(ARCH) $(GPLOBJ)qmclilib.o -o $(GPLBIN)qmclilib.so
	$(COMP) -shared -Wl,$(SONAME_OPT),libqmcli.so -lc $(ARCH) $(GPLOBJ)qmclilib.o -o $(GPLBIN)libqmcli.so

$(GPLBIN)qmtic: $(GPLOBJ)qmtic.o $(GPLOBJ)inipath.o
	$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmtic.o $(GPLOBJ)inipath.o -o $(GPLBIN)qmtic

$(GPLBIN)qmfix: $(GPLOBJ)qmfix.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o $(GPLOBJ)inipath.o
	$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmfix.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o $(GPLOBJ)inipath.o -o $(GPLBIN)qmfix

$(GPLBIN)qmconv: $(GPLOBJ)qmconv.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o
	$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmconv.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o -o $(GPLBIN)qmconv

$(GPLBIN)qmidx: $(GPLOBJ)qmidx.o
	$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmidx.o -o $(GPLBIN)qmidx

$(GPLBIN)qmlnxd: $(GPLOBJ)qmlnxd.o $(GPLOBJ)qmsem.o
	$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmlnxd.o $(GPLOBJ)qmsem.o -o $(GPLBIN)qmlnxd

gplobj/%.o: gplsrc/%.c
	@mkdir -p $(GPLOBJ)
	@mkdir -p $(DEPDIR)
	$(COMP) $(C_FLAGS) -c $< -o $@

-include $(DEPDIR)/*.d

.PHONY: clean install

install:  
ifeq ($(QMUSERS),)
	@echo Creating qm system user and group
	@($(GROUPADD)) --system qmusers
	@usermod -a -G qmusers root
ifeq ($(QMSYS),)
	@($(USERADD)) --system qmsys --gid qmusers
endif
endif

	@echo Compiling terminfo library
	@test -d qmsys/terminfo || mkdir qmsys/terminfo
	cd qmsys && $(GPLBIN)qmtic -pterminfo $(MAIN)terminfo.src

	@echo Installing to $(INSTROOT)
	@rm -Rf $(INSTROOT)
	cp -R qmsys $(INSTROOT)
	chown -R qmsys:qmusers $(INSTROOT)
	chmod -R 664 $(INSTROOT)
	find $(INSTROOT) -type d -print0 | xargs -0 chmod 775

	@ mkdir $(INSTROOT)/bin
	@cp bin/* $(INSTROOT)/bin
	chown qmsys:qmusers $(INSTROOT)/bin $(INSTROOT)/bin/*
	chmod 775 $(INSTROOT)/bin $(INSTROOT)/bin/*

	@echo Writing scarlet.conf file
	@cp $(main)scarlet.conf /etc/scarlet.conf
	@chmod 644 /etc/scarlet.conf

#	Create symbolic link if it does not exist
	@test -f /usr/bin/qm || ln -s /usr/qmsys/bin/qm /usr/bin/qm

#	Install systemd configuration file if needed.
ifneq ($(wildcard $(SYSTEMDPATH)/.),)
	@echo Installing scarletdme.service for systemd.
	@cp usr/lib/systemd/system/* $(SYSTEMDPATH)
	@chown root:root $(SYSTEMDPATH)/scarletdme.service
	@chown root:root $(SYSTEMDPATH)/scarletdmeclient.socket
	@chown root:root $(SYSTEMDPATH)/scarletdmeclient@.service
	@chown root:root $(SYSTEMDPATH)/scarletdmeserver.socket
	@chown root:root $(SYSTEMDPATH)/scarletdmeserver@.service
	@chmod 644 $(SYSTEMDPATH)/scarletdme.service
	@chmod 644 $(SYSTEMDPATH)/scarletdmeclient.socket
	@chmod 644 $(SYSTEMDPATH)/scarletdmeclient@.service
	@chmod 644 $(SYSTEMDPATH)/scarletdmeserver.socket
	@chmod 644 $(SYSTEMDPATH)/scarletdmeserver@.service
endif

#	Install xinetd files if required
ifneq ($(wildcard /etc/xinetd.d/.),)
	@echo Installing xinetd files
	@cp etc/xinetd.d/qmclient /etc/xinetd.d
	@cp etc/xinetd.d/qmserver /etc/xinetd.d
ifneq ($(wildcard /etc/services),)
ifeq ($(shell cat /etc/services | grep qmclient),)
	@cat etc/xinetd.d/services >> /etc/services
endif
endif
endif

clean:
	@rm -f $(GPLOBJ)*.o
	@rm -f $(DEPDIR)*.d
	@rm -f $(GPLBIN)*
	@rm -Rf qmsys/terminfo
