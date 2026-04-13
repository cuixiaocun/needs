<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;

// 健康检查
Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

// 认证路由（无需登录）
Route::post('/auth/register', [RegisterController::class, 'register']);
Route::post('/auth/login', [LoginController::class, 'login']);

// 受保护的路由（需要登录）
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [LoginController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // 订单相关
    Route::post('/orders', [\App\Http\Controllers\OrderController::class, 'store']);
    Route::get('/orders', [\App\Http\Controllers\OrderController::class, 'index']);
    Route::get('/orders/{order}', [\App\Http\Controllers\OrderController::class, 'show']);

    // 订单撮合
    Route::get('/orders/{orderId}/recommendations', [\App\Http\Controllers\MatchingController::class, 'getRecommendations']);
    Route::post('/orders/match', [\App\Http\Controllers\MatchingController::class, 'match']);
    Route::post('/orders/{orderId}/auto-match', [\App\Http\Controllers\MatchingController::class, 'autoMatch']);

    // 支付相关
    Route::post('/payment/alipay/create', [\App\Http\Controllers\PaymentController::class, 'createAlipayment']);
    Route::post('/payment/alipay', [\App\Http\Controllers\PaymentController::class, 'createAlipayment']);
    Route::post('/shipping/estimate', [\App\Http\Controllers\PaymentController::class, 'estimateShipping']);
    Route::post('/shipping/create', [\App\Http\Controllers\PaymentController::class, 'createShippingOrder']);

    // 交货相关
    Route::get('/delivery/fee', [\App\Http\Controllers\DeliveryController::class, 'getFee']);

    // 保证金相关
    Route::get('/deposit', [\App\Http\Controllers\DepositController::class, 'show']);
    Route::post('/deposit/recharge', [\App\Http\Controllers\DepositController::class, 'recharge']);
    Route::post('/deposit/withdraw', [\App\Http\Controllers\DepositController::class, 'withdraw']);
    Route::get('/deposit/logs', [\App\Http\Controllers\DepositController::class, 'logs']);

    // 订单取消相关
    Route::get('/orders/{orderId}/cancel-status', [\App\Http\Controllers\CancelController::class, 'status']);
    Route::post('/orders/{orderId}/cancel/farmer', [\App\Http\Controllers\CancelController::class, 'cancelByFarmer']);
    Route::post('/orders/{orderId}/cancel/buyer', [\App\Http\Controllers\CancelController::class, 'cancelByBuyer']);

    // AI 对话相关（紧急调货）
    Route::prefix('ai')->group(function () {
        Route::post('/chat', [\App\Http\Controllers\AiChatController::class, 'chat']);
        Route::get('/status/{orderId}', [\App\Http\Controllers\AiChatController::class, 'getStatus']);
    });
});

// 支付宝回调（无需认证）
Route::post('/payment/alipay/notify', [\App\Http\Controllers\PaymentController::class, 'alipayNotify'])->name('payment.alipay.notify');
Route::get('/payment/alipay/return', function () {
    return redirect('/'); // 返回首页或订单详情页
})->name('payment.alipay.return');
