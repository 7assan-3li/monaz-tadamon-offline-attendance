<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClubMasterSnapshot extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'club_id',
        'source_device_id',
        'version_timestamp',
        'teams_payload',
        'players_payload',
        'settings_payload',
    ];

    protected function casts(): array
    {
        return [
            'version_timestamp' => 'integer',
            'teams_payload' => 'array',
            'players_payload' => 'array',
            'settings_payload' => 'array',
        ];
    }

    public function club(): BelongsTo
    {
        return $this->belongsTo(ClubProfile::class, 'club_id', 'id');
    }
}
