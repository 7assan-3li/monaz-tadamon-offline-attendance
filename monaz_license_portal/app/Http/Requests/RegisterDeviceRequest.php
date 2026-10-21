<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterDeviceRequest extends FormRequest
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
            'device_id' => 'required|string',
            'device_name' => 'required|string',
            'role' => 'required|in:master_admin,field_scout',
            'club_name' => 'nullable|string',
            'season' => 'nullable|string',
            'primary_color_hex' => 'nullable|string',
        ];
    }
}
