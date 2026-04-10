<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_name' => 'required|string',
            'quantity' => 'required|numeric|min:0',
            'unit' => 'required|string',
            'price_per_unit' => 'required|numeric|min:0',
            'scheduled_delivery_time' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $total_amount = $validated['quantity'] * $validated['price_per_unit'];

        $order = Order::create([
            'farmer_id' => $request->user()->id,
            'product_name' => $validated['product_name'],
            'quantity' => $validated['quantity'],
            'unit' => $validated['unit'],
            'price_per_unit' => $validated['price_per_unit'],
            'total_amount' => $total_amount,
            'scheduled_delivery_time' => $validated['scheduled_delivery_time'] ?? null,
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'data' => $order,
        ], 201);
    }

    public function index(Request $request)
    {
        $orders = Order::where('farmer_id', $request->user()->id)
            ->orWhere('buyer_id', $request->user()->id)
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $orders,
        ]);
    }

    public function show(Order $order)
    {
        return response()->json([
            'success' => true,
            'data' => $order->load('farmer', 'buyer'),
        ]);
    }
}
