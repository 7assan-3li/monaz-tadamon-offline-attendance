<?php

namespace App\Services;

use InvalidArgumentException;
use JsonException;

final class Ed25519SignerService
{
    /**
     * @return array{public_key: string, private_key: string}
     */
    public function generateKeyPair(): array
    {
        $keyPair = sodium_crypto_sign_keypair();

        return [
            'public_key' => base64_encode(sodium_crypto_sign_publickey($keyPair)),
            'private_key' => base64_encode(sodium_crypto_sign_secretkey($keyPair)),
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{canonical_payload: string, signature: string}
     *
     * @throws JsonException
     */
    public function sign(array $payload, string $privateKey): array
    {
        $privateKeyBytes = $this->decodeKey(
            $privateKey,
            SODIUM_CRYPTO_SIGN_SECRETKEYBYTES,
            'private key',
        );
        $canonicalPayload = $this->canonicalJson($payload);

        return [
            'canonical_payload' => $canonicalPayload,
            'signature' => base64_encode(
                sodium_crypto_sign_detached($canonicalPayload, $privateKeyBytes),
            ),
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     *
     * @throws JsonException
     */
    public function verify(array $payload, string $signature, string $publicKey): bool
    {
        $signatureBytes = $this->decodeKey(
            $signature,
            SODIUM_CRYPTO_SIGN_BYTES,
            'signature',
        );
        $publicKeyBytes = $this->decodeKey(
            $publicKey,
            SODIUM_CRYPTO_SIGN_PUBLICKEYBYTES,
            'public key',
        );

        return sodium_crypto_sign_verify_detached(
            $signatureBytes,
            $this->canonicalJson($payload),
            $publicKeyBytes,
        );
    }

    /**
     * @param  array<string, mixed>  $payload
     *
     * @throws JsonException
     */
    public function canonicalJson(array $payload): string
    {
        return json_encode(
            $this->sortRecursively($payload),
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR,
        );
    }

    private function sortRecursively(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map($this->sortRecursively(...), $value);
        }

        ksort($value, SORT_STRING);

        return array_map($this->sortRecursively(...), $value);
    }

    private function decodeKey(string $encodedValue, int $expectedLength, string $label): string
    {
        $decodedValue = base64_decode($encodedValue, true);

        if ($decodedValue === false || strlen($decodedValue) !== $expectedLength) {
            throw new InvalidArgumentException("Invalid Ed25519 {$label}.");
        }

        return $decodedValue;
    }
}
