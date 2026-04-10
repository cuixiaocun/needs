<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // 支付宝配置
    'alipay' => [
        'app_id' => env('ALIPAY_APP_ID'),
        'private_key' => env('ALIPAY_PRIVATE_KEY'),
        'public_key' => env('ALIPAY_PUBLIC_KEY'),
        'sandbox' => env('ALIPAY_SANDBOX', true),
    ],

    // 货拉拉配置
    'huolala' => [
        'api_key' => env('HUOLALA_API_KEY'),
        'sandbox' => env('HUOLALA_SANDBOX', true),
    ],

    // 阿里云配置
    'aliyun' => [
        'access_key' => env('ALIYUN_ACCESS_KEY'),
        'secret_key' => env('ALIYUN_SECRET_KEY'),
        'region' => env('ALIYUN_REGION', 'cn-shanghai'),
        'sms_sign_name' => env('ALIYUN_SMS_SIGN_NAME', 'Needs平台'),
        'email_account' => env('ALIYUN_EMAIL_ACCOUNT'),
        'sms_templates' => [
            'register' => env('ALIYUN_SMS_TEMPLATE_REGISTER'),
            'login' => env('ALIYUN_SMS_TEMPLATE_LOGIN'),
            'reset' => env('ALIYUN_SMS_TEMPLATE_RESET'),
        ],
    ],

    // DeepSeek AI 配置（用于紧急调货 AI 对话）
    'deepseek' => [
        'api_key' => env('DEEPSEEK_API_KEY'),
        'base_url' => env('DEEPSEEK_BASE_URL', 'https://api.deepseek.com/v1'),
    ],

];
