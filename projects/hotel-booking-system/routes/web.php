<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RoomController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AdminRoomController;
use App\Http\Controllers\AdminBookingController;
use App\Http\Controllers\AdminReportController;

Route::get('/', function () {
    return view('welcome');
});

Route::resource('users', UserController::class);
Route::resource('rooms', RoomController::class);
Route::get('rooms/availability', [RoomController::class, 'availability'])->name('rooms.availability');
Route::resource('bookings', BookingController::class);
Route::resource('reviews', ReviewController::class);

Route::prefix('admin')->middleware(['auth', 'admin'])->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
    Route::resource('/rooms', AdminRoomController::class);
    Route::resource('/bookings', AdminBookingController::class);
    Route::get('/reports', [AdminReportController::class, 'index'])->name('admin.reports');
});
