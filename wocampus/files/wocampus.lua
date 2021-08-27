#!/usr/bin/lua

require 'campus'

require 'luci.model.uci'
require 'luci.util'


function sleep(s)
	luci.util.exec('sleep ' .. s)
end

function notify(content, interface)
	if interface then
		luci.util.ubus('network.interface', 'notify_proto', {
			interface = interface,
			action = 3,
			error = { tostring(content) }
		})
		
		luci.util.ubus('log', 'write', {
			event = '%s: %s' % {interface, tostring(content)}
		})
	else
		luci.util.ubus('log', 'write', {
			event = 'wocampus: %s' % tostring(content)
		})
	end
end

function do_login(interface)
	local obj = campus:new(interface.device)
	local res, err = obj:login(interface.username, interface.password, interface.ip)
	if err then return nil, err	end
	
	res, err = obj:check()
	if not res then return nil, 'can not check device'
	elseif tonumber(res.NET_STATUS) == 1 then
		if not obj:kick() then return nil, 'can not kick device' end
	end
	
	return obj:post(redirect_url)
end

function get_campus_inferfaces()
	local interfaces = {}
	for k, network in pairs(luci.model.uci.cursor_state():get_all("network")) do
		local status = luci.util.ubus('network.interface.%s' % network['.name'], 'status', {})
		if network['.type'] == 'interface' and network['proto'] == 'wocampus' and status['ipv4-address'] then
			table.insert(interfaces, {
				name = network['.name'],
				device = status['l3_device'],
				ip = status['ipv4-address'][1]['address'],
				
				username = network.username,
				password = network.password
			});
		end
	end
	return interfaces
end

notify 'hello wocampus'

while true do
	for k, interface in pairs(get_campus_inferfaces()) do
		local check_result = campus.check_net(interface.device)
		if(check_result ~= true and check_result ~= false) then
			notify 'network is not ok, should login'
			
			local res, err = do_login(interface)
			if not res or err then
				notify(err or 'can not auth', interface['name'])
				luci.util.ubus('network.interface.%s' % interface['name'], 'down', {})
			end
		end
	end
	
	sleep(30)
end

