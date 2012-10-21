PREFIX=/easytomato/easyoptionals
HOST=mipsel-linux
BUILD=x86_64-unknown-linux-gnu
COMMON_CFG_OPTS=--host=$(HOST) --prefix=$(PREFIX) -C
NUM_THREADS=4
RPATH=/easytomato/easytoptionals/lib
LDFLAGS=LDFLAGS="-R $(RPATH)"

##############################################
# Application Specific Configuration Options #
##############################################

#
# Squid
#
SQUID_SRC=squid-3.1.20.tar.gz
SQUID_URL=http://www.squid-cache.org/Versions/v3/3.1/$(SQUID_SRC)
SQUID_DIR=$(subst .tar.gz,,$(SQUID_SRC))
SQUID_CFG_OPTS=--enable-linux-netfilter --enable-basic-auth-helpers="POP3 SMB"

#
# GDB
#
GDB_DIR=gdb-7.4
GDB_CFG_OPTS=--target=$(HOST) --build=$(BUILD) --with-curses

all:$(SQUID_DIR)/squid.built #$(GDB_DIR)/gdb.built
	@echo "Everything up to date!"

######################################
# Application Specific Build Targets #
######################################

#
# Squid
#
$(SQUID_SRC):
	wget $(SQUID_URL)

$(SQUID_DIR): $(SQUID_SRC)
	tar -xzf $(SQUID_SRC)

$(SQUID_DIR)/config.cache: |$(SQUID_DIR)
	cd $(SQUID_DIR); ./configure $(COMMON_CFG_OPTS) $(SQUID_CFG_OPTS)

$(SQUID_DIR)/squid.built: $(SQUID_DIR)/config.cache
	cd $(SQUID_DIR) && \
	cp ../misc/cf_gen src/. && \
	$(MAKE) $(LDFLAGS) && \
	$(MAKE) install && \
	touch squid.built

#
# GDB
#
$(GDB_DIR)/gdb.built: $(GDB_DIR)/config.cache
	cd $(GDB_DIR) && \
	$(MAKE) && \
	$(MAKE) install && \
	touch gdb.built

$(GDB_DIR)/config.cache:
	cd $(GDB_DIR); ./configure $(COMMON_CFG_OPTS) $(GDB_CFG_OPTS)

#
# Misc
#
print-%:
	@echo $* = $($*)

distclean: 
	rm -rf \
	$(SQUID_DIR) \
	$(SQUID_SRC)