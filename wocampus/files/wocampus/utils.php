<?php

error_reporting(E_ERROR);

const URL_PORTAL = "http://connect.rom.miui.com/generate_204";

class utils
{
	public static function uuid($p = '-')
	{
		$chars = md5(uniqid(mt_rand(), true));
		$uuid = substr($chars, 0, 8) . $p;
		$uuid .= substr($chars, 8, 4) . $p;
		$uuid .= substr($chars, 12, 4) . $p;
		$uuid .= substr($chars, 16, 4) . $p;
		$uuid .= substr($chars, 20, 12);
		return $uuid;
	}

	public static function getPortalUrl($interface)
	{
		$curl = curl_init(URL_PORTAL);

		curl_setopt($curl, CURLOPT_INTERFACE, $interface);
		curl_setopt($curl, CURLOPT_FOLLOWLOCATION, false);
		curl_setopt($curl, CURLOPT_NOBODY, true);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_HEADER, true);

		curl_exec($curl);

		if (curl_errno($curl)) {
			throw new Exception("Curl error: " . curl_error($curl));
		}

		$url = curl_getinfo($curl, CURLINFO_REDIRECT_URL);

		curl_close($curl);
		if ($url && strpos($url, "campus")) {
			return $url;
		}
		return false;
	}

	public static function generateRealParams($url, $loginData)
	{
		if (!defined("HMAC_SECRET_KEY")) return false;
		if (!defined("DES_SECRET_KEY_POST")) return false;
		return array(
			'LOGIN_TYPE' => hash_hmac("sha1", json_encode($loginData) . basename($url), HMAC_SECRET_KEY),
			'inparam' => openssl_encrypt(json_encode($loginData), 'des-ecb', DES_SECRET_KEY_POST)
		);
	}

	public static function requestData($interface, $url, $loginData)
	{
		$url = $url . "?" . http_build_query(self::generateRealParams($url, $loginData));

		$curl = curl_init($url);
		curl_setopt($curl, CURLOPT_HTTPHEADER, array(
			'Accept-Encoding: gzip, deflate'
		));
		curl_setopt($curl, CURLOPT_ENCODING, "gzip, deflate");
		curl_setopt($curl, CURLOPT_INTERFACE, $interface);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_TIMEOUT, 10);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
		curl_setopt($curl, CURLOPT_USERAGENT, "android,lbs");

		$output = curl_exec($curl);

		if (curl_errno($curl)) {
			throw new Exception("Curl error: " . curl_error($curl));
		}
		curl_close($curl);

		if (!defined("DES_SECRET_KEY_RESULT")) return false;
		$obj = json_decode(openssl_decrypt($output, 'des-ecb', DES_SECRET_KEY_RESULT));
		if (!$obj) {
			throw new Exception("can not decode json: '$output'");
		}

		if ((int)$obj->SUCCESS === 0) {
			return $obj;
		} else {
			throw new Exception(trim($obj->ERRORINFO));
		}
	}

}
