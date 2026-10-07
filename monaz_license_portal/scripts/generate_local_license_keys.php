<?php

declare(strict_types=1);

$projectRoot = dirname(__DIR__);
$flutterRoot = dirname($projectRoot).DIRECTORY_SEPARATOR.'tadamon_attendance_app';
$environmentPath = $projectRoot.DIRECTORY_SEPARATOR.'.env';
$definesPath = $flutterRoot.DIRECTORY_SEPARATOR.'.dart-defines.local.json';

if (! file_exists($environmentPath)) {
    copy($projectRoot.DIRECTORY_SEPARATOR.'.env.example', $environmentPath);
}

$keyPair = sodium_crypto_sign_keypair();
$privateKey = base64_encode(sodium_crypto_sign_secretkey($keyPair));
$publicKey = base64_encode(sodium_crypto_sign_publickey($keyPair));
$fingerprintSalt = base64_encode(random_bytes(32));

$environment = file_get_contents($environmentPath);
$entry = 'LARAVEL_ED25519_PRIVATE_KEY='.$privateKey;
if (preg_match('/^LARAVEL_ED25519_PRIVATE_KEY=.*$/m', $environment) === 1) {
    $environment = preg_replace('/^LARAVEL_ED25519_PRIVATE_KEY=.*$/m', $entry, $environment);
} else {
    $environment .= PHP_EOL.$entry.PHP_EOL;
}
file_put_contents($environmentPath, $environment);

file_put_contents($definesPath, json_encode([
    'MONAZ_ED25519_PUBLIC_KEY' => $publicKey,
    'MONAZ_HARDWARE_FINGERPRINT_SALT' => $fingerprintSalt,
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR).PHP_EOL);

echo "Local Ed25519 keys and Android build defines generated without exposing the private key.\n";
