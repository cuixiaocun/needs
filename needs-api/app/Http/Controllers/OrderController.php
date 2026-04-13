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
            'type' => 'required|in:sell,buy',
            'quality_level' => 'required|in:特级,一级,二级',
            'scheduled_delivery_time' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $total_amount = $validated['quantity'] * $validated['price_per_unit'];

        $order = Order::create([
            'farmer_id' => $request->user()->id,
            'buyer_id' => null,
            'product_name' => $validated['product_name'],
            'quantity' => $validated['quantity'],
            'unit' => $validated['unit'],
            'price_per_unit' => $validated['price_per_unit'],
            'total_amount' => $total_amount,
            'type' => $validated['type'],
            'quality_level' => $validated['quality_level'],
            'status' => 'pending',
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
        $query = Order::where('farmer_id', $request->user()->id)
            ->orWhere('buyer_id', $request->user()->id);

        // 按状态筛选
        if ($request->has('status') && !empty($request->input('status'))) {
            $query->where('status', $request->input('status'));
        }

        // 按类型筛选
        if ($request->has('type') && !empty($request->input('type'))) {
            $query->where('type', $request->input('type'));
        }

        // 按时间倒序排列
        $orders = $query->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $orders->items(),
            'current_page' => $orders->currentPage(),
            'last_page' => $orders->lastPage(),
            'total' => $orders->total(),
            'per_page' => $orders->perPage(),
        ]);
    }

    public function show(Order $order, Request $request)
    {
        // 权限检查：只能查看自己的订单
        if ($order->farmer_id !== $request->user()->id && $order->buyer_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => '无权限访问此订单',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $order->load('farmer', 'buyer'),
        ]);
    }

    public function update(Order $order, Request $request)
    {
        // 权限检查：订单创建者才能更新
        if ($order->farmer_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => '无权限修改此订单',
            ], 403);
        }

        $validated = $request->validate([
            'matched_order_id' => 'nullable|integer|exists:orders,id',
            'status' => 'nullable|in:pending,confirmed,receiving,received,dispatched,completed,cancelled',
            'scheduled_delivery_time' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $order->update($validated);

        return response()->json([
            'success' => true,
            'data' => $order,
        ]);
    }
}
