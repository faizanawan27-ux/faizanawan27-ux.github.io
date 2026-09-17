<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $primaryKey = 'booking_id';

    protected $casts = [
        'check_in_date' => 'date',
        'check_out_date' => 'date',
    ];

    public function calculateTotal()
    {
        $roomType = $this->room->roomType;
        $nights = $this->check_in_date->diffInDays($this->check_out_date);
        $this->total_amount = $roomType->base_price * $nights;

        // Add services
        $servicesTotal = $this->services->sum('price');
        $this->total_amount += $servicesTotal;

        return $this;
    }

    public function scopeUpcoming($query)
    {
        return $query->where('check_out_date', '>=', now())
            ->where('booking_status', 'confirmed');
    }
}
