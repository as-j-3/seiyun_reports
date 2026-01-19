<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lifting_Area extends Model
{
    public function Areas()
    {
        return $this->belongsTo(Area::class,'area_id');
    }
}
