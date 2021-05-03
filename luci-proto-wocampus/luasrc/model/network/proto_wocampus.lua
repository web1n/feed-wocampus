local proto = luci.model.network:register_protocol("wocampus")

function proto.get_i18n(self)
	return luci.i18n.translate("Hebei Unicom Wo Campus Client")
end

function proto.opkg_package(self)
	return "wocampus"
end

function proto.is_installed(self)
	return nixio.fs.access("/lib/netifd/proto/wocampus.sh")
end
