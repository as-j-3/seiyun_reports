<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    public function reportAssignments() 
    {
        return $this->hasMany(Report_Assignment::class, 'report_id');
    }
}
