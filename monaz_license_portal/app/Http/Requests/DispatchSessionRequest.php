<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DispatchSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'session_uuid' => 'required|string',
            'team_id' => 'required|string',
            'session_date' => 'required|date',
            'source_device_id' => 'required|string',
            'absentees' => 'present|array',
            'signature' => 'nullable|string',
        ];
    }
}
