require 'nixio.fs'

require 'luci.util'
require 'luci.jsonc'

openssl = require 'openssl'


local URL_DO_LOGIN = "https://icampus.hbwo10010.cn/ncampus/pfdoLogin"
local URL_KICK_DEVICE = "https://icampus.hbwo10010.cn/ncampus/kickNetAccount"
local URL_CONNECT_NET = "https://icampus.hbwo10010.cn/controlplatform/netConnect"
local URL_GET_NET_STATE = "https://icampus.hbwo10010.cn/controlplatform/getNetStateFromAccount"
local URL_PORTAL = "http://connect.rom.miui.com/generate_204"

local DES_SECRET_KEY_POST = "Fly@T2lI"
local DES_SECRET_KEY_RESULT = "Song$2Mq"
local HMAC_SECRET_KEY = "liU%yFt2"


campus = {}

function campus:new(interface)
	obj = {}
	obj.interface = interface
	
	setmetatable(obj, {
		__index = self
	})
	return obj
end


local function uuid()
	return nixio.fs.readfile('/proc/sys/kernel/random/uuid')
end

function parse_url(url)
	local params = {}

	local path = url:split'?'
	if(#path ~= 2) then return params end
	path = path[2]

	for k, v in pairs(path:split'&') do
		local args = v:split'='
		if(#args == 2) then
			params[args[1]] = args[2]
		end
	end

	return params
end

function des_encrypt(enc, data, key)
	local des = openssl.cipher.get'des-ecb'
	
	if(enc) then
		return openssl.base64(des:encrypt(data, key))
	else
		return des:decrypt(openssl.base64(string.gsub(data, '\n', ''), false), key)
	end
end

function http_build_query(params)
	local request_data = {}
	for k,v in pairs(params) do
		table.insert(request_data, '%s=%s' % {k, luci.util.urlencode(v)})
	end

	return table.concat(request_data, '&')
end

function generate_real_params(url, data)
	return http_build_query {
		LOGIN_TYPE = openssl.hmac.hmac('sha1', data .. nixio.fs.basename(url), HMAC_SECRET_KEY, false),
		inparam = des_encrypt(true, data, DES_SECRET_KEY_POST)
	}
end

function curl_get(url, interface)
	local command = "curl -i -s --user-agent 'android,lbs' --connect-timeout 1 '%s'" % url
	if(interface ~= nil) then
		command = '%s --interface %s' % {command, interface}
	end
	
	local result = luci.util.exec(command):split'\r\n\r\n'
	if(#result ~= 2) then return 0, nil, {} end
	
	local data = result[2]
	if(#data == 0) then data = nil end
	
	local code = tonumber(result[1]:split' '[2])

	local response_headers = {}
	for k, line in pairs(result[1]:split'\n') do
		local args = line:split': '
		if(#args == 2) then
			response_headers[args[1]:lower()] = args[2]
		end
	end
	
	return code, data, response_headers
end

function request_data(url, request_data, interface)
	local url = url .. '?' .. generate_real_params(url, luci.jsonc.stringify(request_data))
	
	local code, result = curl_get(url, interface)
	if code ~= 200 or result == nil then
		return nil, 'err to request: %d' % code
	end
	
	local data = des_encrypt(false, result, DES_SECRET_KEY_RESULT)

	result = luci.jsonc.parse(data)
	if(tonumber(result.SUCCESS) ~= 0) then
		return nil, result.ERRORINFO
	else
		return result, nil
	end
end

function campus.check_net(interface)
	local code, data, response_headers = curl_get(URL_PORTAL, interface)
	if(code == 204) then
		return true
	elseif(response_headers.location ~= nil) then
		return response_headers.location
	else
		return false
	end
end


function campus:login(username, password, ip)
	local data = {
		IP_ADDRESS = ip,
		AUTH_METH = '0',
		APP_VERSION = '2.3.2',
		RANDOM_CODE = string.gsub(uuid(), '-', ''),
		OS_VERSION = '10',
		OS = 'ANDROID',
		PASSWORD = password,
		PHONE_TYPE = 'Android',
		PHONE_NAME = 'Android Device',
		PHONE_NUMBER = username
	}
	
	local res, err = request_data(URL_DO_LOGIN, data, self.interface)
	
	if res then
		self.token = res.TOKEN
		self.account_id = res.ACCOUNT_ID
		
		self.net_account = res.ACCOUNT_NET
		self.net_password = res.PASSWORD_NET
		
		return self
	end
	return nil, err
end

function campus:check()
	if not self.token then return nil, 'need login' end

	local data = {
		NET_ACCOUNT = self.net_account,
		TOKEN = self.token,
		ACCOUNT_ID = self.account_id
	}
	
	return request_data(URL_GET_NET_STATE, data, self.interface)
end

function campus:kick()
	if not self.token then return nil, 'need login' end

	local data = {
		DEVICE_TYPE = '01',
		ACCOUNT_TYPE = '1',
		TOKEN = self.token,
		ACCOUNT_ID = self.account_id
	}
	
	return request_data(URL_KICK_DEVICE, data, self.interface)
end

function campus:post(redirect_url)
	if not self.token then return nil, 'need login' end
	if not redirect_url then return nil, 'need redirect url' end

	local params = parse_url(redirect_url)
	if not (params['user-mac'] or params.usermac) or not params.userip then
		return nil, 'err parse redirect'
	end
	
	local data = {
		MAC = params['user-mac'] or params.usermac,
		IP = params.userip,
		REDIRECTURL = redirect_url,
		
		NET_ACCOUNT = self.net_account,
		NET_PASSWD = self.net_password,
		
		ACCOUNT_ID = self.accunt_id,
		TOKEN = self.token
	}
	
	local result = request_data(URL_CONNECT_NET, data, self.interface)
	if(result == nil) then
		return
	elseif(tonumber(result.NET_STATUS) ~= 1) then
		return nil, result.ERRORINFO
	else
		return result, nil
	end
end


return campus
