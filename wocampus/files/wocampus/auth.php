<?php

include("utils.php");

define("URL_DO_LOGIN", "https://icampus.hbwo10010.cn/ncampus/pfdoLogin");
define("URL_CONNECT_NET", "https://icampus.hbwo10010.cn/controlplatform/netConnect");
define("URL_GET_NET_STATE", "https://icampus.hbwo10010.cn/controlplatform/getNetStateFromAccount");
define("URL_KICK_DEVICE", "https://icampus.hbwo10010.cn/ncampus/kickNetAccount");

define("DES_SECRET_KEY_POST", "Fly@T2lI");
define("DES_SECRET_KEY_RESULT", "Song$2Mq");
define("HMAC_SECRET_KEY", "liU%yFt2");


class auth
{

	private $bindInterface;

	public function __construct($interface)
	{
		$this->bindInterface = $interface;
	}

	public function login($username, $password)
	{
		$ip = gethostbyname(null);

		return utils::requestData($this->bindInterface, URL_DO_LOGIN, array(
			"IP_ADDRESS" => $ip,
			"IMEI" => null,
			"AUTH_METH" => "0",
			"RANDOM_CODE" => utils::uuid(""),
			"OS_VERSION" => "10",
			"OS" => "ANDROID",
			"PASSWORD" => $password,
			"PHONE_TYPE" => "Android",
			"PHONE_NAME" => "Android Device",
			"APP_VERSION" => "2.3.2",
			"PHONE_NUMBER" => $username
		));
	}

	public function checkDevice($accountId, $netAccount, $token)
	{
		if (!defined("URL_GET_NET_STATE")) return false;
		return utils::requestData($this->bindInterface, URL_GET_NET_STATE, array(
			"NET_ACCOUNT" => $netAccount,
			"TOKEN" => $token,
			"ACCOUNT_ID" => $accountId
		));
	}

	public function kickDevice($accountId, $token)
	{
		if (!defined("URL_KICK_DEVICE")) return false;
		return utils::requestData($this->bindInterface, URL_KICK_DEVICE, array(
			"DEVICE_TYPE" => "01",
			"ACCOUNT_TYPE" => "1",
			"TOKEN" => $token,
			"ACCOUNT_ID" => $accountId
		));
	}

	public function getRedirectUrl()
	{
		$portalUrl = utils::getPortalUrl($this->bindInterface);
		if (!$portalUrl) {
			throw new Exception("can not get portal url");
		}

		return $portalUrl;
	}

	public function post($redirectUrl, $netAccount, $netPassword, $accountId, $token)
	{
		parse_str(parse_url($redirectUrl)["query"], $queries);

		if (!defined("URL_CONNECT_NET")) return false;
		$result = utils::requestData($this->bindInterface, URL_CONNECT_NET, array(
			"MAC" => $queries["usermac"] ?? $queries["user-mac"],
			"IP" => $queries["userip"],
			"REDIRECTURL" => $redirectUrl,
			"TOKEN" => $token,
			"ACCOUNT_ID" => $accountId,
			"NET_ACCOUNT" => $netAccount,
			"NET_PASSWD" => $netPassword
		));

		if ((int)$result->NET_STATUS === 1) {
			return $result;
		} else {
			throw new Exception($result->ERRORINFO);
		}
	}

}
