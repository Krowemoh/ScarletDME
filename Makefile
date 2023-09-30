# default target builds 64-bit, build qm32 target for a 32-bit build

COMP     := gcc
OSNAME   := $(shell uname -s)

MAIN     := $(shell pwd)/
GPLSRC   := $(MAIN)gplsrc/
GPLDOTSRC := $(MAIN)utils/gpl.src

GPLOBJ   := $(MAIN)gplobj/
GPLBIN   := $(MAIN)bin/
DEPDIR := $(MAIN)deps/

ifeq (Darwin,$(OSNAME))
	L_FLAGS  := -lm -ldl -lcrypto
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

SOURCES := $(filter-out gplsrc/qmclient.c, $(wildcard gplsrc/*.c))
OBJECTS = $(patsubst gplsrc/%.c, gplobj/%.o, $(SOURCES))

TARGETS = $(OBJECTS) $(GPLBIN)qmclilib.so $(GPLBIN)qmtic $(GPLBIN)qmfix $(GPLBIN)qmconv $(GPLBIN)qmidx $(GPLBIN)qmlnxd terminfo

C_FLAGS = -Wall -Wformat=2 -Wno-format-nonliteral -DLINUX -D_FILE_OFFSET_BITS=64 -I$(GPLSRC) -DGPL -g $(ARCH) -fPIE -fPIC -MMD -MF $(DEPDIR)/$*.d

qm: ARCH :=
qm: $(TARGETS)
	@echo "Linking qm."
	@$(COMP) $(ARCH) $(L_FLAGS) $(QMOBJSD) -o $(GPLBIN)qm

qm32: ARCH := -m32
qm32: $(TARGETS)
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

terminfo: $(GPLBIN)qmtic	
	@echo Compiling terminfo library
	@test -d qmsys/terminfo || mkdir qmsys/terminfo
	cd qmsys && $(GPLBIN)qmtic -pterminfo $(MAIN)utils/terminfo.src

gplobj/%.o: gplsrc/%.c
	@mkdir -p $(GPLBIN)
	@mkdir -p $(GPLOBJ)
	@mkdir -p $(DEPDIR)
	$(COMP) $(C_FLAGS) -c $< -o $@

-include $(DEPDIR)/*.d

install:  
	@echo Installing to $(INSTROOT)
	@rm -Rf $(INSTROOT)
	cp -R qmsys $(INSTROOT)
	chown -R qmsys:qmusers $(INSTROOT)
	chmod -R 664 $(INSTROOT)
	find $(INSTROOT) -type d -print0 | xargs -0 chmod 775

	@mkdir $(INSTROOT)/bin
	@cp bin/* $(INSTROOT)/bin
	@cp utils/pcode $(INSTROOT)/bin/pcode
	chown qmsys:qmusers $(INSTROOT)/bin $(INSTROOT)/bin/*
	chmod 775 $(INSTROOT)/bin $(INSTROOT)/bin/*

	@echo Writing scarlet.conf file
	@cp utils/scarlet.conf /etc/scarlet.conf
	@chmod 644 /etc/scarlet.conf

	@test -f /usr/bin/qm || ln -s /usr/qmsys/bin/qm /usr/bin/qm

clean:
	@rm -Rf $(GPLOBJ)
	@rm -Rf $(DEPDIR)
	@rm -Rf $(GPLBIN)
	@rm -Rf qmsys/terminfo
