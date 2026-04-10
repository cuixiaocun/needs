<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'farmer_id',
        'buyer_id',
        'product_name',
        'quantity',
        'unit',
        'price_per_unit',
        'total_amount',
        'status',
        'scheduled_delivery_time',
        'notes',
    ];

    protected $casts = [
        'scheduled_delivery_time' => 'datetime',
    ];

    public function farmer()
    {
        return $this->belongsTo(User::class, 'farmer_id');
    }

    public function buyer()
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }
}
