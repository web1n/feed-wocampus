#
# Copyright (C) 2020 web1n
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wocampus
PKG_RELEASE:=1
PKG_VERSION:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wocampus
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=WoCampus
	PKGARCH:=all
	DEPENDS:=+lua +lua-openssl +luci-base +curl
endef

define Build/Compile
	true
endef

define Package/wocampus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) ./files/campus.lua $(1)/usr/lib/lua/campus.lua
	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/wocampus.lua $(1)/usr/sbin/wocampus.lua
	
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/wocampus.sh $(1)/lib/netifd/proto/wocampus.sh
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wocampus.init $(1)/etc/init.d/wocampus
endef

$(eval $(call BuildPackage,wocampus))
