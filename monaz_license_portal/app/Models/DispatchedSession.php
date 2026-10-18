<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DispatchedSession extends Model
{
    protected $primaryKey = 'session_uuid';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'session_uuid',
        'team_id',
        'session_date',
        'source_device_id',
        'payload',
        'signature',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'session_date' => 'datetime',
            'payload' => 'array',
        ];
    }
}
