<?php

namespace App\Http\Controllers;

use App\Services\DeliveryService;

/**
 * 交货信息控制器
 */
class DeliveryController extends Controller
{
    private DeliveryService $deliveryService;

    public function __construct(DeliveryService $deliveryService)
    {
        $this->deliveryService = $deliveryService;
    }

    /**
     * 获取交货信息和费用
     *
     * GET /api/delivery/fee
     */
    public function getFee()
    {
        $info = $this->deliveryService->getDeliveryInfo();

        return response()->json([
            'success' => true,
            'data' => $info
        ]);
    }
}
