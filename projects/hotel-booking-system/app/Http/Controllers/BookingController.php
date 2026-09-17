<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,user_id',
            'room_id' => 'required|exists:rooms,room_id',
            'check_in_date' => 'required|date|after:today',
            'check_out_date' => 'required|date|after:check_in_date',
        ]);

        // Check room availability
        $conflictingBookings = Booking::where('room_id', $validated['room_id'])
            ->where('check_out_date', '>', $validated['check_in_date'])
            ->where('check_in_date', '<', $validated['check_out_date'])
            ->count();

        if ($conflictingBookings > 0) {
            return back()->withErrors(['Room is not available for the selected dates']);
        }

        $booking = Booking::create($validated);

        return redirect()->route('bookings.show', $booking);
    }
}
