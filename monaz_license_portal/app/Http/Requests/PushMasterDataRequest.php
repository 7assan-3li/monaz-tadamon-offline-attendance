<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PushMasterDataRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'club_id' => 'nullable|string|max:50',
            'source_device_id' => 'required|string',
            'version_timestamp' => 'nullable|integer',
            'club_profile' => 'nullable|array',
            'teams' => 'present|array',
            'players' => 'present|array',
        ];
    }
}
