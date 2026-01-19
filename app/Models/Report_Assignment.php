<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report_Assignment extends Model
{
    public function report() {
        return $this->belongsTo(Report::class,'report_id');
    }

    public function supervisor() {
        return $this->belongsTo(User::class, 'supervisor_id');
    }

}
