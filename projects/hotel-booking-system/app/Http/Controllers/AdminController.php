<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Payment;
use App\Models\Room;
use App\Models\RoomType;

class AdminController extends Controller
{
    public function dashboard()
    {
        $bookings = Booking::with(['user', 'room'])->latest()->take(10)->get();
        $recentPayments = Payment::with('booking')->latest()->take(5)->get();
        $roomOccupancy = Room::selectRaw('room_type, count(*) as total,
            sum(case when status = "Booked" then 1 else 0 end) as booked')
            ->groupBy('room_type')
            ->get();

        return view('admin.dashboard', compact('bookings', 'recentPayments', 'roomOccupancy'));
    }

    public function manageRooms()
    {
        $rooms = Room::with('roomType')->get();
        $roomTypes = RoomType::all();

        return view('admin.rooms.index', compact('rooms', 'roomTypes'));
    }
}
