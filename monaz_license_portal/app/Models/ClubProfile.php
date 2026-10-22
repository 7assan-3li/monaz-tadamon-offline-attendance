<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ClubProfile extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'club_code',
        'club_name',
        'season',
        'admin_name',
        'manager_name',
        'primary_color_hex',
        'logo_url',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function devices(): HasMany
    {
        return $this->hasMany(ClubDevice::class, 'club_id', 'id');
    }

    public function snapshots(): HasMany
    {
        return $this->hasMany(ClubMasterSnapshot::class, 'club_id', 'id');
    }

    public function dispatchedSessions(): HasMany
    {
        return $this->hasMany(DispatchedSession::class, 'club_id', 'id');
    }
}
