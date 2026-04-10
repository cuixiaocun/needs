<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Facades\Log;

/**
 * 订单撮合引擎
 *
 * 功能：
 * 1. 精确匹配：相同产品、数量、价格
 * 2. 模糊匹配：相近价格和数量
 * 3. 自动确认：匹配成功自动更新订单状态
 */
class MatchingService
{
    /**
     * 精确匹配
     *
     * 规则：
     * - 相同产品名称
     * - 农户和买家都已确认
     * - 数量相符
     * - 价格相符（允许 5% 误差）
     */
    public function exactMatch(Order $farmerOrder)
    {
        try {
            $match = Order::where('product_name', $farmerOrder->product_name)
                ->where('quantity', $farmerOrder->quantity)
                ->where('price_per_unit', '>=', $farmerOrder->price_per_unit * 0.95)
                ->where('price_per_unit', '<=', $farmerOrder->price_per_unit * 1.05)
                ->where('farmer_id', '!=', $farmerOrder->farmer_id)
                ->where('buyer_id', '!=', null) // 买家已提交
                ->where('status', 'pending')
                ->first();

            if (!$match) {
                Log::info('未找到精确匹配', ['order_id' => $farmerOrder->id]);
                return null;
            }

            // 自动确认订单
            $this->confirmMatch($farmerOrder, $match);

            return $match;
        } catch (\Exception $e) {
            Log::error('精确匹配失败', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * 模糊匹配（AI 撮合）
     *
     * 规则：
     * - 相同或相似产品
     * - 数量在 80%-120% 之间
     * - 价格在 -10% 到 +10% 之间
     * - 计算匹配分数，取最高分
     */
    public function fuzzyMatch(Order $farmerOrder, $topN = 5)
    {
        try {
            $candidates = Order::where('product_name', 'like', '%' . $farmerOrder->product_name . '%')
                ->where('quantity', '>=', $farmerOrder->quantity * 0.8)
                ->where('quantity', '<=', $farmerOrder->quantity * 1.2)
                ->where('price_per_unit', '>=', $farmerOrder->price_per_unit * 0.9)
                ->where('price_per_unit', '<=', $farmerOrder->price_per_unit * 1.1)
                ->where('farmer_id', '!=', $farmerOrder->farmer_id)
                ->where('buyer_id', '!=', null)
                ->where('status', 'pending')
                ->get();

            if ($candidates->isEmpty()) {
                Log::info('未找到模糊匹配候选', ['order_id' => $farmerOrder->id]);
                return collect();
            }

            // 计算每个候选的匹配分数
            $scored = $candidates->map(function ($order) use ($farmerOrder) {
                return [
                    'order' => $order,
                    'score' => $this->calculateMatchScore($farmerOrder, $order),
                ];
            })->sortByDesc('score')->take($topN);

            Log::info('模糊匹配完成', [
                'order_id' => $farmerOrder->id,
                'candidates' => $scored->count(),
            ]);

            return $scored->pluck('order');
        } catch (\Exception $e) {
            Log::error('模糊匹配失败', ['error' => $e->getMessage()]);
            return collect();
        }
    }

    /**
     * 手动匹配（买家主动选择农户）
     */
    public function manualMatch(Order $buyerOrder, Order $farmerOrder)
    {
        try {
            if ($buyerOrder->farmer_id !== null) {
                return [
                    'success' => false,
                    'error' => '订单已配对，请取消后重新配对',
                ];
            }

            if ($farmerOrder->buyer_id !== null) {
                return [
                    'success' => false,
                    'error' => '农户订单已配对',
                ];
            }

            // 验证商品和数量匹配
            if ($buyerOrder->product_name !== $farmerOrder->product_name) {
                return [
                    'success' => false,
                    'error' => '产品名称不符',
                ];
            }

            if ($buyerOrder->quantity !== $farmerOrder->quantity) {
                return [
                    'success' => false,
                    'error' => '数量不符',
                ];
            }

            $this->confirmMatch($farmerOrder, $buyerOrder);

            return [
                'success' => true,
                'message' => '配对成功',
            ];
        } catch (\Exception $e) {
            Log::error('手动匹配失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 确认撮合
     */
    protected function confirmMatch(Order $farmerOrder, Order $buyerOrder)
    {
        // 更新订单状态
        $farmerOrder->update([
            'buyer_id' => $buyerOrder->buyer_id ?? $buyerOrder->id,
            'status' => 'confirmed',
        ]);

        $buyerOrder->update([
            'farmer_id' => $farmerOrder->farmer_id,
            'status' => 'confirmed',
        ]);

        Log::info('订单已撮合', [
            'farmer_order_id' => $farmerOrder->id,
            'buyer_order_id' => $buyerOrder->id,
        ]);
    }

    /**
     * 计算匹配分数（0-100）
     *
     * 分数由以下因素组成：
     * - 产品匹配度（40%）
     * - 数量匹配度（30%）
     * - 价格匹配度（30%）
     */
    protected function calculateMatchScore(Order $farmerOrder, Order $buyerOrder)
    {
        $score = 0;

        // 1. 产品匹配度（40%）
        $productSimilarity = $this->calculateStringSimilarity(
            $farmerOrder->product_name,
            $buyerOrder->product_name
        );
        $score += $productSimilarity * 40;

        // 2. 数量匹配度（30%）
        $quantityRatio = min($farmerOrder->quantity, $buyerOrder->quantity) /
                        max($farmerOrder->quantity, $buyerOrder->quantity);
        $quantityScore = $quantityRatio >= 0.8 ? 30 : $quantityRatio * 30;
        $score += $quantityScore;

        // 3. 价格匹配度（30%）
        $priceDiff = abs($farmerOrder->price_per_unit - $buyerOrder->price_per_unit) /
                    $farmerOrder->price_per_unit;
        $priceScore = max(0, 30 * (1 - $priceDiff));
        $score += $priceScore;

        return round($score, 2);
    }

    /**
     * 计算字符串相似度（0-1）
     * 使用莱文斯坦距离算法
     */
    protected function calculateStringSimilarity($str1, $str2)
    {
        if ($str1 === $str2) {
            return 1;
        }

        $len1 = strlen($str1);
        $len2 = strlen($str2);
        $maxLen = max($len1, $len2);

        if ($maxLen === 0) {
            return 1;
        }

        $distance = levenshtein($str1, $str2);
        return 1 - ($distance / $maxLen);
    }

    /**
     * 获取订单的推荐匹配列表
     */
    public function getRecommendations(Order $order, $limit = 5)
    {
        $matches = $this->fuzzyMatch($order, $limit);

        return $matches->map(function ($match) use ($order) {
            return [
                'id' => $match->id,
                'farmer_name' => $match->farmer->name,
                'product' => $match->product_name,
                'quantity' => $match->quantity,
                'unit' => $match->unit,
                'price_per_unit' => $match->price_per_unit,
                'total_amount' => $match->total_amount,
                'score' => $this->calculateMatchScore($order, $match),
            ];
        });
    }
}
