<?php

namespace App\Integrations;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

/**
 * 支付宝集成模块
 *
 * 功能：
 * - 创建支付链接
 * - 验证支付回调
 * - 查询订单状态
 */
class AlipayIntegration
{
    protected $client;
    protected $appId;
    protected $privateKey;
    protected $publicKey;
    protected $isSandbox;
    protected $gatewayUrl;

    public function __construct()
    {
        $this->appId = config('services.alipay.app_id');
        $this->privateKey = config('services.alipay.private_key');
        $this->publicKey = config('services.alipay.public_key');
        $this->isSandbox = config('services.alipay.sandbox', true);

        $this->gatewayUrl = $this->isSandbox
            ? 'https://openapi.alipaydev.com/gateway.do'
            : 'https://openapi.alipay.com/gateway.do';

        $this->client = new Client([
            'timeout' => 30,
        ]);
    }

    /**
     * 创建支付订单（页面支付）
     */
    public function createPagePayment($orderId, $amount, $subject, $returnUrl, $notifyUrl)
    {
        try {
            $params = [
                'app_id' => $this->appId,
                'method' => 'alipay.trade.page.pay',
                'charset' => 'UTF-8',
                'sign_type' => 'RSA2',
                'timestamp' => date('Y-m-d H:i:s'),
                'version' => '1.0',
                'notify_url' => $notifyUrl,
                'return_url' => $returnUrl,
                'biz_content' => json_encode([
                    'out_trade_no' => (string)$orderId,
                    'product_code' => 'FAST_INSTANT_TRADE_PAY',
                    'total_amount' => (string)$amount,
                    'subject' => $subject,
                ]),
            ];

            // 生成签名
            $params['sign'] = $this->sign($params);

            // 构建支付 URL
            $paymentUrl = $this->gatewayUrl . '?' . http_build_query($params);

            Log::info('支付宝支付链接生成', ['order_id' => $orderId, 'amount' => $amount]);

            return [
                'success' => true,
                'payment_url' => $paymentUrl,
            ];
        } catch (\Exception $e) {
            Log::error('支付宝支付链接生成失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 验证支付回调签名
     */
    public function verifyNotify($data)
    {
        try {
            $sign = $data['sign'] ?? null;
            unset($data['sign']);

            // 按照支付宝规范排序参数
            ksort($data);

            $signData = '';
            foreach ($data as $key => $value) {
                if ($value === '' || $value === null) {
                    continue;
                }
                if ($signData) {
                    $signData .= '&';
                }
                $signData .= $key . '=' . $value;
            }

            // 验证签名
            return $this->verifySign($signData, $sign);
        } catch (\Exception $e) {
            Log::error('支付宝回调验证失败', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * 查询订单状态
     */
    public function queryOrder($orderId)
    {
        try {
            $params = [
                'app_id' => $this->appId,
                'method' => 'alipay.trade.query',
                'charset' => 'UTF-8',
                'sign_type' => 'RSA2',
                'timestamp' => date('Y-m-d H:i:s'),
                'version' => '1.0',
                'biz_content' => json_encode([
                    'out_trade_no' => (string)$orderId,
                ]),
            ];

            $params['sign'] = $this->sign($params);

            $response = $this->client->post($this->gatewayUrl, [
                'form_params' => $params,
            ]);

            $result = json_decode($response->getBody()->getContents(), true);

            return [
                'success' => true,
                'data' => $result,
            ];
        } catch (\Exception $e) {
            Log::error('支付宝订单查询失败', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 生成签名
     */
    protected function sign($params)
    {
        unset($params['sign']);
        ksort($params);

        $signData = '';
        foreach ($params as $key => $value) {
            if ($value === '' || $value === null) {
                continue;
            }
            if ($signData) {
                $signData .= '&';
            }
            $signData .= $key . '=' . $value;
        }

        openssl_sign($signData, $signature, $this->privateKey, 'sha256WithRSAEncryption');
        return base64_encode($signature);
    }

    /**
     * 验证签名
     */
    protected function verifySign($data, $sign)
    {
        $publicKey = "-----BEGIN PUBLIC KEY-----\n" .
                     wordwrap($this->publicKey, 64, "\n", true) .
                     "\n-----END PUBLIC KEY-----";

        return openssl_verify($data, base64_decode($sign), $publicKey, 'sha256WithRSAEncryption') === 1;
    }
}
