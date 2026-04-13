<?php

namespace App\Services;

/**
 * 交货信息服务
 */
class DeliveryService
{
    /**
     * 默认交货地点
     */
    const DEFAULT_LOCATION = '集散市场中转';

    /**
     * 默认运费（单位：元）
     */
    const DEFAULT_FEE = 80;

    /**
     * 获取交货信息
     *
     * @return array
     */
    public function getDeliveryInfo()
    {
        return [
            'location' => self::DEFAULT_LOCATION,
            'fee' => self::DEFAULT_FEE,
            'description' => '标准物流运费'
        ];
    }

    /**
     * 获取交货费用
     *
     * @return int
     */
    public function getDeliveryFee()
    {
        return self::DEFAULT_FEE;
    }

    /**
     * 获取交货地点
     *
     * @return string
     */
    public function getDeliveryLocation()
    {
        return self::DEFAULT_LOCATION;
    }
}
