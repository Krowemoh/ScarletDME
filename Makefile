# default target builds 64-bit, build qm32 target for a 32-bit build

GROUPADD := $(shell command -v adduser 2> /dev/null || command -v groupadd 2> /dev/null)
USERADD := $(shell command -v addgroup 2> /dev/null || command -v useradd 2> /dev/null)

MAIN     := $(shell pwd)/
GPLSRC   := $(MAIN)gplsrc/
GPLDOTSRC := $(MAIN)gpl.src
GPLOBJ   := $(MAIN)gplobj/
GPLBIN   := $(MAIN)bin/
TERMINFO := $(MAIN)qmsys/terminfo/
VPATH    := $(GPLOBJ):$(GPLBIN):$(GPLSRC)

ifneq ($(wildcard /usr/lib/systemd/system/.),)
	SYSTEMDPATH := /usr/lib/systemd/system
else
	SYSTEMDPATH := /lib/systemd/system
endif

OSNAME   := $(shell uname -s)

COMP     := gcc

ifeq (Darwin,$(OSNAME))
	ARCH :=
	BITSIZE := 64
	C_FLAGS  := -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH)
	L_FLAGS  := -lm -ldl
	INSTROOT := /opt/qmsys
	SONAME_OPT := -install_name
else
	L_FLAGS  := -Wl,--no-as-needed -lm -lcrypt -ldl -lcrypto
	INSTROOT := /usr/qmsys
	SONAME_OPT := -soname
endif

QMHDRS   := $(wildcard *.h)
QMSRCS   := $(shell cat $(GPLDOTSRC))
QMTEMP   := $(addsuffix .o,$(QMSRCS))
QMOBJS   := $(QMTEMP)
QMOBJSD  := $(addprefix $(GPLOBJ),$(QMTEMP))
TEMPSRCS := $(wildcard *.c)
SRCS     := $(TEMPSRCS:qmclient.c=)
OBJS     := $(SRCS:.c=.o)
DIROBJS  := $(addprefix $(GPLOBJ),$(OBJS))
QMSYS   := $(shell cat /etc/passwd | grep qmsys)
QMUSERS := $(shell cat /etc/group | grep qmusers)

qm: ARCH :=
qm: BITSIZE := 64
qm: C_FLAGS  := -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH) -fPIE
qm: $(QMOBJS) qmclilib.so qmtic qmfix qmconv qmidx qmlnxd
	@echo Linking $@
	@cd $(GPLOBJ)
	@$(COMP) $(ARCH) $(L_FLAGS) $(QMOBJSD) -o $(GPLBIN)qm

qm32: ARCH := -m32
qm32: BITSIZE := 32
qm32: C_FLAGS  := -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH)
qm32: $(QMOBJS) qmclilib.so qmtic qmfix qmconv qmidx qmlnxd
	@echo Linking $@
	@$(COMP) $(ARCH) $(L_FLAGS) $(QMOBJSD) -o $(GPLBIN)qm

qmclilib.so: qmclilib.o
	@echo Linking $@
	@$(COMP) -shared -Wl,$(SONAME_OPT),qmclilib.so -lc $(ARCH) $(GPLOBJ)qmclilib.o -o $(GPLBIN)qmclilib.so
	@$(COMP) -shared -Wl,$(SONAME_OPT),libqmcli.so -lc $(ARCH) $(GPLOBJ)qmclilib.o -o $(GPLBIN)libqmcli.so

qmtic: qmtic.o inipath.o
	@echo Linking $@
	@$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmtic.o $(GPLOBJ)inipath.o -o $(GPLBIN)qmtic

qmfix: qmfix.o ctype.o linuxlb.o dh_hash.o inipath.o
	@echo Linking $@
	@$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmfix.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o $(GPLOBJ)inipath.o -o $(GPLBIN)qmfix

qmconv: qmconv.o ctype.o linuxlb.o dh_hash.o
	@echo Linking $@
	@$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmconv.o $(GPLOBJ)ctype.o $(GPLOBJ)linuxlb.o $(GPLOBJ)dh_hash.o -o $(GPLBIN)qmconv

qmidx: qmidx.o
	@echo Linking $@
	@$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmidx.o -o $(GPLBIN)qmidx

qmlnxd: qmlnxd.o qmsem.o
	@echo Linking $@
	@$(COMP) $(C_FLAGS) -lc $(GPLOBJ)qmlnxd.o $(GPLOBJ)qmsem.o -o $(GPLBIN)qmlnxd

qmclilib.o: qmclilib.c revstamp.h
	@echo Compiling $@ with -fPIC
	@$(COMP) $(C_FLAGS) -fPIC -c $(GPLSRC)qmclilib.c -o $(GPLOBJ)qmclilib.o

# We need to make sure that anything that includes revstamp.h gets built if revstamp.h 
# changes.

config.o: config.c config.h qm.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)config.o

kernel.o: kernel.c qm.h revstamp.h header.h tio.h debug.h keys.h syscom.h config.h \
	options.h dh_int.h locks.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)kernel.o

op_kernel.o: op_kernel.c qm.h revstamp.h header.h tio.h debug.h keys.h syscom.h \
	config.h options.h dh_int.h locks.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)op_kernel.o

op_sys.o: op_sys.c qm.h header.h tio.h syscom.h dh_int.h revstamp.h config.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)op_sys.o

pdump.o: pdump.c qm.h header.h syscom.h config.h revstamp.h locks.h dh_int.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)pdump.o

qm.o:	qm.c qm.h revstamp.h header.h debug.h dh_int.h tio.h config.h options.h \
	locks.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qm.o 

qmclient.o: qmclient.c qmdefs.h revstamp.h qmclient.h err.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qmclient.o

qmconv.o: qmconv.c qm.h dh_int.h header.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qmconv.o

qmfix.o: qmfix.c qm.h dh_int.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qmfix.o

qmidx.o: qmidx.c qm.h dh_int.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qmidx.o

qmtic.o: qmtic.c ti_names.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)qmtic.o

sysdump.o: sysdump.c qm.h locks.h revstamp.h config.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)sysdump.o

sysseg.o: sysseg.c qm.h locks.h config.h revstamp.h
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)sysseg.o

.c.o:
	@echo Compiling $@, $(BITSIZE) bit target.
	@$(COMP) $(C_FLAGS) -c $< -o $(GPLOBJ)$@

.PHONY: clean install qmdev qmstop

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
ifeq ($(wildcard $(INSTROOT)/.),)
#	qmsys doesn't exist, so copy it to the live location
	cp -R qmsys $(INSTROOT)
	chown -R qmsys:qmusers $(INSTROOT)
	chmod -R 664 $(INSTROOT)
	find $(INSTROOT) -type d -print0 | xargs -0 chmod 775
#	else update everything that's changed, eg NEWVOC, MESSAGES, all that sort of stuff.
else
#	copy FILEs that need updating
#	copy the contents of NEWVOC so the account will upgrade
	@rm -f $(INSTROOT)/NEWVOC/*
	@cp qmsys/NEWVOC/* $(INSTROOT)/NEWVOC
	@chown qmsys:qmusers $(INSTROOT)/NEWVOC/*
	@chmod 664 $(INSTROOT)/NEWVOC/*

#	copy the contents of MESSAGES so the account will upgrade
	@rm -f $(INSTROOT)/MESSAGES/*
	@cp qmsys/MESSAGES/* $(INSTROOT)/MESSAGES
	@chown qmsys:qmusers $(INSTROOT)/MESSAGES/*
	@chmod 664 $(INSTROOT)/MESSAGES/*

#	copy the contents of terminfo so the account will upgrade
	@rm -Rf $(INSTROOT)/terminfo/*
	@cp -R qmsys/terminfo/* $(INSTROOT)/terminfo
	@chown qmsys:qmusers $(INSTROOT)/terminfo/*
	@chmod 664 $(INSTROOT)/terminfo/*

endif
#       copy bin files and make them executable
	@test -d $(INSTROOT)/bin || mkdir $(INSTROOT)/bin
#	copy the contents of bin so the account will upgrade
	@rm -f $(INSTROOT)/bin/*
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

distclean: clean
	@rm -f $(GPLBIN)*
	@rm -f $(GPLSRC)terminfo
