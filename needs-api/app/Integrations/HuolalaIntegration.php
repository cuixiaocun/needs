<?php

namespace App\Integrations;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

/**
 * 货拉拉集成模块
 *
 * 功能：
 * - 运费预估
 * - 创建运输订单
 * - 查询订单状态
 */
class HuolalaIntegration
{
    protected $client;
    protected $apiKey;
    protected $isSandbox;
    protected $baseUri;

    public function __construct()
    {
        $this->apiKey = config('services.huolala.api_key');
        $this->isSandbox = config('services.huolala.sandbox', true);

        $this->baseUri = $this->isSandbox
            ? 'https://sandbox-api.huolala.cn'
            : 'https://openapi.huolala.cn';

        $this->client = new Client([
            'base_uri' => $this->baseUri,
            'timeout' => 30,
        ]);
    }

    /**
     * 获取运费预估
     */
    public function estimatePrice($from, $to, $weight = 1, $volume = 1)
    {
        try {
            $response = $this->client->post('/api/carpool/order/estimatedPrice', [
                'headers' => $this->getHeaders(),
                'json' => [
                    'from' => $from,
                    'to' => $to,
                    'weight' => $weight,
                    'volume' => $volume,
                    'cargoType' => 1, // 蔬菜/农产品
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            Log::info('货拉拉运费预估成功', ['from' => $from, 'to' => $to]);

            return [
                'success' => true,
                'data' => $result,
            ];
        } catch (\Exception $e) {
            Log::error('货拉拉运费预估失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 创建运输订单
     */
    public function createOrder($orderId, $from, $to, $items, $weight, $volume, $remark = '')
    {
        try {
            $response = $this->client->post('/api/carpool/order/createOrder', [
                'headers' => $this->getHeaders(),
                'json' => [
                    'outTradeNo' => (string)$orderId,
                    'from' => $from,
                    'to' => $to,
                    'items' => $items, // [['name' => '产品名', 'quantity' => 数量]]
                    'weight' => $weight,
                    'volume' => $volume,
                    'remark' => $remark,
                    'cargoType' => 1,
                    'cargoDesc' => '农产品',
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            Log::info('货拉拉订单创建成功', ['order_id' => $orderId, 'logistics_id' => $result['id'] ?? null]);

            return [
                'success' => true,
                'logistics_id' => $result['id'] ?? null,
                'data' => $result,
            ];
        } catch (\Exception $e) {
            Log::error('货拉拉订单创建失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 查询订单状态
     */
    public function queryOrder($logisticsId)
    {
        try {
            $response = $this->client->get('/api/carpool/order/queryOrder', [
                'headers' => $this->getHeaders(),
                'query' => [
                    'id' => $logisticsId,
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            return [
                'success' => true,
                'data' => $result,
                'status' => $result['status'] ?? null,
            ];
        } catch (\Exception $e) {
            Log::error('货拉拉订单查询失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 取消订单
     */
    public function cancelOrder($logisticsId, $reason = '')
    {
        try {
            $response = $this->client->post('/api/carpool/order/cancelOrder', [
                'headers' => $this->getHeaders(),
                'json' => [
                    'id' => $logisticsId,
                    'reason' => $reason,
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            Log::info('货拉拉订单取消成功', ['logistics_id' => $logisticsId]);

            return [
                'success' => true,
                'data' => $result,
            ];
        } catch (\Exception $e) {
            Log::error('货拉拉订单取消失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 获取请求头
     */
    protected function getHeaders()
    {
        return [
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
            'User-Agent' => 'NeedsPlatform/1.0',
        ];
    }
}
