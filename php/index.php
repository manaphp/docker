<?php

$http = new Swoole\Http\Server('0.0.0.0', 9501);

$http->on('Request', function ($request, $response) {
    $response->header('Content-Type', 'text/html; charset=utf-8');
    $response->end('<h1>Hello Swoole: #' . rand(1000, 9999) . '</h1>' . SWOOLE_VERSION . PHP_EOL);
});

$http->start();