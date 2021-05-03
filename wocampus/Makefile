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
	DEPENDS:=+curl +php7 +php7-cli +php7-mod-curl +php7-mod-json +php7-mod-openssl
endef

define Build/Compile
	true
endef

define Package/wocampus/install
	$(INSTALL_DIR) $(1)/usr/lib/wocampus
	$(INSTALL_BIN) ./files/wocampus/* $(1)/usr/lib/wocampus/
	
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/wocampus.sh $(1)/lib/netifd/proto/wocampus.sh
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wocampus.init $(1)/etc/init.d/wocampus
endef

$(eval $(call BuildPackage,wocampus))
