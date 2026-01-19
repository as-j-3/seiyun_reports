<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Area extends Model
{
    public function liftingAreas()
    {
        return $this->hasOne(Lifting_Area::class);
    }

    public function sweepingAreas()
    {
        return $this->hasOne(Sweeping_Area::class);
    }

    public function supervisor()
    {
        return $this->belongsTo(User::class,'supervisor_id');
    }

    public function containersLocations()
    {
        return $this->hasMany(Containers_Location::class);
    }
    public function reports()
    {
        return $this->hasMany(Report::class);
    }
}
