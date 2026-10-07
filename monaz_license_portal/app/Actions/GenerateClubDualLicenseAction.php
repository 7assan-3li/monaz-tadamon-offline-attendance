<?php

namespace App\Actions;

use App\Data\GenerateClubDualLicenseData;
use App\Services\Ed25519SignerService;
use InvalidArgumentException;
use JsonException;
use RuntimeException;

final readonly class GenerateClubDualLicenseAction
{
    public function __construct(private Ed25519SignerService $signer) {}

    /**
     * @return array{master: array<string, mixed>, field: array<string, mixed>}
     *
     * @throws JsonException
     */
    public function execute(GenerateClubDualLicenseData $data): array
    {
        $this->guardInput($data);

        $privateKey = config('licensing.ed25519_private_key');
        if (! is_string($privateKey) || $privateKey === '') {
            throw new RuntimeException('The Ed25519 private key is not configured.');
        }

        $pairingSecret = $this->base64UrlEncode(random_bytes(32));

        return [
            'master' => $this->issueLicense(
                $this->payload($data, 'MASTER_ADMIN', $data->masterDeviceId, $data->fieldDeviceId, $pairingSecret),
                $privateKey,
            ),
            'field' => $this->issueLicense(
                $this->payload($data, 'FIELD_ATTENDANCE', $data->fieldDeviceId, $data->masterDeviceId, $pairingSecret),
                $privateKey,
            ),
        ];
    }

    /** @return array<string, string|null> */
    private function payload(
        GenerateClubDualLicenseData $data,
        string $role,
        string $deviceId,
        string $pairedDeviceId,
        string $pairingSecret,
    ): array {
        return [
            'activated_at' => $data->activatedAt->setTimezone(new \DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
            'club_name' => $data->clubName,
            'device_id' => $deviceId,
            'expires_at' => $data->expiresAt->setTimezone(new \DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
            'local_pairing_secret' => $pairingSecret,
            'package_type' => $data->packageType,
            'paired_device_id' => $pairedDeviceId,
            'role' => $role,
            'team_name' => $data->teamName,
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{activation_code: string, payload: array<string, mixed>, signature: string}
     *
     * @throws JsonException
     */
    private function issueLicense(array $payload, string $privateKey): array
    {
        $signedPayload = $this->signer->sign($payload, $privateKey);
        $envelope = json_encode([
            'payload' => $payload,
            'signature' => $signedPayload['signature'],
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);

        return [
            'activation_code' => $this->base64UrlEncode($envelope),
            'payload' => $payload,
            'signature' => $signedPayload['signature'],
        ];
    }

    private function guardInput(GenerateClubDualLicenseData $data): void
    {
        foreach ([$data->masterDeviceId, $data->fieldDeviceId] as $deviceId) {
            if (preg_match('/^TD-[A-Z0-9]{4}-[A-Z0-9]{4}$/', $deviceId) !== 1) {
                throw new InvalidArgumentException('Invalid hardware fingerprint.');
            }
        }

        if ($data->masterDeviceId === $data->fieldDeviceId) {
            throw new InvalidArgumentException('Master and field devices must be different.');
        }

        if ($data->expiresAt <= $data->activatedAt) {
            throw new InvalidArgumentException('License expiry must be after activation.');
        }
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
