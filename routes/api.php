<?php
require __DIR__.'/admin.php';
require __DIR__.'/supervisor.php';
require __DIR__.'/citizen.php';

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
