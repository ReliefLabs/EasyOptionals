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
SQUID_BIN=$(PREFIX)/bin/squidclient

#
# GDB
#
GDB_DIR=gdb-7.4
GDB_CFG_OPTS=--target=$(HOST) --build=$(BUILD) --with-curses
GDB_BIN=$(PREFIX)/bin/gdb

#
# tcpdump
#
TCPDUMP_MAKE_PREFIX=CC=`which mipsel-linux-gcc`
LIBPCAP_SRC=libpcap-1.3.0.tar.gz
TCPDUMP_SRC=tcpdump-4.3.0.tar.gz
LIBPCAP_URL=http://www.tcpdump.org/release/$(LIBPCAP_SRC)
TCPDUMP_URL=http://www.tcpdump.org/release/$(TCPDUMP_SRC)
LIBPCAP_DIR=$(subst .tar.gz,,$(LIBPCAP_SRC))
TCPDUMP_DIR=$(subst .tar.gz,,$(TCPDUMP_SRC))
LIBPCAP_CFG_OPTS=--with-pcap=linux
TCPDUMP_CFG_OPTS=$(LIBPCAP_CFG_OPTS) ac_cv_linux_vers=2
TCPDUMP_BIN=$(PREFIX)/sbin/tcpdump


all:$(SQUID_BIN) $(TCPDUMP_BIN) #$(GDB_BIN)
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
	cd $(SQUID_DIR) && \
	./configure $(COMMON_CFG_OPTS) $(SQUID_CFG_OPTS)

$(SQUID_BIN): $(SQUID_DIR)/config.cache
	cp ./misc/cf_gen $(SQUID_DIR)/src/.
	$(MAKE) -C $(SQUID_DIR) $(LDFLAGS)
	$(MAKE) -C $(SQUID_DIR) install

#
# GDB
#
$(GDB_DIR)/gdb: $(GDB_DIR)/config.cache
	$(MAKE) -C $(GDB_DIR)

$(GDB_BIN): $(GDB_DIR)/gdb
	$(MAKE) -C $(GDB_DIR) install

$(GDB_DIR)/config.cache:
	cd $(GDB_DIR) && \
	 ./configure $(COMMON_CFG_OPTS) $(GDB_CFG_OPTS)

#
# tcpdump
#
$(TCPDUMP_SRC):
	wget $(LIBPCAP_URL)
	wget $(TCPDUMP_URL)

$(TCPDUMP_DIR): $(TCPDUMP_SRC)
	tar -xzf $(TCPDUMP_SRC)

$(LIBPCAP_DIR): $(LIBPCAP_SRC)
	tar -xzf $(LIBPCAP_SRC)

$(LIBPCAP_DIR)/config.cache: |$(LIBPCAP_DIR)
	cd $(LIBPCAP_DIR) && \
	$(TCPDUMP_MAKE_PREFIX) ./configure $(COMMON_CFG_OPTS) $(LIBPCAP_CFG_OPTS)

$(TCPDUMP_DIR)/config.cache: |$(TCPDUMP_DIR) $(LIBPCAP_DIR)/libpcap.a
	cd $(TCPDUMP_DIR) && \
	$(TCPDUMP_MAKE_PREFIX) ./configure $(COMMON_CFG_OPTS) $(TCPDUMP_CFG_OPTS)

$(LIBPCAP_DIR)/libpcap.a: $(LIBPCAP_DIR)/config.cache
	$(MAKE) -C $(LIBPCAP_DIR)
	$(MAKE) -C $(LIBPCAP_DIR) install

$(TCPDUMP_BIN): $(TCPDUMP_DIR)/config.cache
	$(MAKE) -C $(TCPDUMP_DIR)
	$(MAKE) -C $(TCPDUMP_DIR) install


#
# Misc
#
print-%:
	@echo $* = $($*)

clean:
	$(MAKE) -C $(SQUID_DIR) clean
	$(MAKE) -C $(GDB_DIR) clean

distclean: 
	rm -rf \
	$(SQUID_DIR) \
	$(SQUID_SRC)