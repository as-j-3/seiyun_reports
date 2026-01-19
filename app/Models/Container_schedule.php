<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Container_schedule extends Model
{
    const COLLECTION_DAYS = [
        'daily'     => 'يوميًا',
        'alternate' => 'يوم بعد يوم',
        'sunday'    => 'الأحد',
        'monday'    => 'الاثنين',
        'tuesday'   => 'الثلاثاء',
        'wednesday' => 'الأربعاء',
        'thursday'  => 'الخميس',
        'friday'    => 'الجمعة',
        'saturday'  => 'السبت',
    ];

    public function containersLocations()
    {
        return $this->belongsTo(Containers_Location::class,'container_id');
    }
}
