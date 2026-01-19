<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Containers_Location extends Model
{
    public function areas()
    {
        return $this->belongsTo(Area::class,'area_id');
    }
    public function containerSchedules()
    {
        return $this->hasOne(Container_schedule::class);
    }
}
