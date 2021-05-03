<?php

include("auth.php");

function shutdown_handler() {
	$error = error_get_last();
	if ($error && in_array($error['type'], [E_ERROR, E_PARSE])) {
		system("logger -t wocampus " . strtok($error['message'], PHP_EOL));
	}
}
register_shutdown_function('shutdown_handler');


if (count($argv) != 4) {
	throw new Exception("username or password is null\n");
}
$username = $argv[1];
$password = $argv[2];
$interface = $argv[3];

$auth = new auth($interface);

echo "Getting account info...\n";
$authData = $auth->login($username, $password);
echo "Account login successfully: account: $authData->ACCOUNT_ID\n";

$accountId = $authData->ACCOUNT_ID;
$token = $authData->TOKEN;
$netAccount = $authData->ACCOUNT_NET;
$netPassword = $authData->PASSWORD_NET;

echo "Checking online device...\n";
$onlineData = $auth->checkDevice($accountId, $netAccount, $token);
if ((int)$onlineData->NET_STATUS === 1) {
	echo "Online device detected: $onlineData->MAC $onlineData->IP\n";

	$kick = $auth->kickDevice($accountId, $token);
	echo "$kick->ERRORINFO\n";
} else {
	echo "Not detected online device\n";
}

# get ip and mac
echo "Getting Redirect Url...\n";
$redirectUrl = $auth->getRedirectUrl();
echo "$redirectUrl\n";

# post
echo "Perform login...\n";
$loginResult = $auth->post($redirectUrl, $netAccount, $netPassword, $accountId, $token);
echo "$loginResult->ERRORINFO\n";