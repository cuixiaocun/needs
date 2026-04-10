<?php

namespace App\Integrations;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

/**
 * 阿里云集成模块
 *
 * 功能：
 * - 短信发送
 * - 实名认证
 */
class AliyunIntegration
{
    protected $client;
    protected $accessKey;
    protected $secretKey;
    protected $region;
    protected $smsSignName;
    protected $smsTemplates;

    public function __construct()
    {
        $this->accessKey = config('services.aliyun.access_key');
        $this->secretKey = config('services.aliyun.secret_key');
        $this->region = config('services.aliyun.region', 'cn-shanghai');
        $this->smsSignName = config('services.aliyun.sms_sign_name', 'Needs平台');
        $this->smsTemplates = config('services.aliyun.sms_templates', [
            'register' => 'SMS_XXXX', // 用户注册验证码
            'login' => 'SMS_XXXX',    // 用户登录验证码
            'reset' => 'SMS_XXXX',    // 密码重置验证码
        ]);

        $this->client = new Client([
            'timeout' => 30,
        ]);
    }

    /**
     * 发送短信
     */
    public function sendSms($phoneNumber, $templateKey, $params = [])
    {
        try {
            $templateCode = $this->smsTemplates[$templateKey] ?? null;
            if (!$templateCode) {
                throw new \Exception("短信模板 {$templateKey} 不存在");
            }

            // 构建请求
            $requestParams = [
                'PhoneNumbers' => $phoneNumber,
                'SignName' => $this->smsSignName,
                'TemplateCode' => $templateCode,
                'TemplateParam' => json_encode($params),
                'Action' => 'SendSms',
                'Version' => '2017-01-12',
            ];

            // 签名请求（阿里云签名规范）
            $response = $this->makeRequest('https://dysmsapi.aliyuncs.com/', $requestParams);

            $result = simplexml_load_string($response);

            if ($result && $result->Code == 'OK') {
                Log::info('短信发送成功', ['phone' => $phoneNumber, 'template' => $templateKey]);
                return [
                    'success' => true,
                    'message_id' => (string)$result->BizId,
                ];
            } else {
                Log::warning('短信发送失败', ['phone' => $phoneNumber, 'error' => (string)$result->Message]);
                return [
                    'success' => false,
                    'error' => (string)($result->Message ?? 'Unknown error'),
                ];
            }
        } catch (\Exception $e) {
            Log::error('短信发送异常', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 实名认证（三要素：姓名、身份证号、手机号）
     */
    public function verifyRealname($name, $idNumber, $phoneNumber)
    {
        try {
            $requestParams = [
                'Action' => 'VerifyPersonalInfo',
                'Version' => '2018-07-24',
                'Name' => $name,
                'IdCard' => $idNumber,
                'Phone' => $phoneNumber,
            ];

            $response = $this->makeRequest('https://cloudauth.aliyuncs.com/', $requestParams);

            $result = simplexml_load_string($response);

            if ($result && $result->Code == 'OK') {
                $verified = (string)$result->Verified === 'true';
                Log::info('实名认证完成', ['verified' => $verified]);
                return [
                    'success' => true,
                    'verified' => $verified,
                    'message' => (string)($result->Message ?? ''),
                ];
            } else {
                Log::warning('实名认证失败', ['error' => (string)$result->Message]);
                return [
                    'success' => false,
                    'error' => (string)($result->Message ?? 'Verification failed'),
                ];
            }
        } catch (\Exception $e) {
            Log::error('实名认证异常', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 发送邮件通知
     */
    public function sendEmail($toAddress, $subject, $htmlBody)
    {
        try {
            $requestParams = [
                'Action' => 'SingleSendMail',
                'Version' => '2015-11-23',
                'AccountName' => config('services.aliyun.email_account'),
                'FromAlias' => 'Needs平台',
                'ToAddress' => $toAddress,
                'Subject' => $subject,
                'HtmlBody' => $htmlBody,
            ];

            $response = $this->makeRequest('https://dm.aliyuncs.com/', $requestParams);

            $result = simplexml_load_string($response);

            if ($result && $result->RequestId) {
                Log::info('邮件发送成功', ['to' => $toAddress]);
                return [
                    'success' => true,
                    'request_id' => (string)$result->RequestId,
                ];
            } else {
                return [
                    'success' => false,
                    'error' => '邮件发送失败',
                ];
            }
        } catch (\Exception $e) {
            Log::error('邮件发送异常', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * 构建签名并发送请求（简化版）
     *
     * 注意：实际使用中应使用阿里云官方 SDK
     */
    protected function makeRequest($endpoint, $params)
    {
        // 添加公共参数
        $commonParams = [
            'Format' => 'XML',
            'AccessKeyId' => $this->accessKey,
            'SignatureVersion' => '1.0',
            'SignatureMethod' => 'HMAC-SHA1',
            'SignatureNonce' => uniqid(),
            'Timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
        ];

        $params = array_merge($params, $commonParams);
        ksort($params);

        // 生成签名字符串
        $signString = $this->buildSignString($params);
        $signature = base64_encode(hash_hmac('sha1', $signString, $this->secretKey . '&', true));

        $params['Signature'] = $signature;

        // 发送请求
        $response = $this->client->get($endpoint, [
            'query' => $params,
        ]);

        return $response->getBody()->getContents();
    }

    /**
     * 构建签名字符串
     */
    protected function buildSignString($params)
    {
        $query = [];
        foreach ($params as $key => $value) {
            $query[] = urlencode($key) . '=' . urlencode($value);
        }

        return 'GET&' . urlencode('/') . '&' . urlencode(implode('&', $query));
    }
}
