<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Room;
use App\Models\RoomType;
use Carbon\Carbon;
use Illuminate\Http\Request;

class RoomAvailabilityController extends Controller
{
    public function index(Request $request)
    {
        $rooms = Room::with(['bookings', 'roomType'])->get();
        $roomTypes = RoomType::all();
        $selectedMonth = $request->input('month', date('Y-m'));

        return view('admin.availability.index', compact('rooms', 'roomTypes', 'selectedMonth'));
    }

    public function getAvailabilityData(Request $request)
    {
        $request->validate([
            'room_id' => 'required|exists:rooms,room_id',
            'month' => 'required|date_format:Y-m',
        ]);

        $startDate = Carbon::parse($request->month)->startOfMonth();
        $endDate = Carbon::parse($request->month)->endOfMonth();

        $bookings = Booking::where('room_id', $request->room_id)
            ->where(function ($query) use ($startDate, $endDate) {
                $query->whereBetween('check_in_date', [$startDate, $endDate])
                    ->orWhereBetween('check_out_date', [$startDate, $endDate])
                    ->orWhere(function ($q) use ($startDate, $endDate) {
                        $q->where('check_in_date', '<', $startDate)
                            ->where('check_out_date', '>', $endDate);
                    });
            })
            ->where('booking_status', 'confirmed')
            ->get();

        $availability = [];
        $currentDate = clone $startDate;

        while ($currentDate <= $endDate) {
            $isAvailable = true;
            foreach ($bookings as $booking) {
                if ($currentDate >= $booking->check_in_date && $currentDate < $booking->check_out_date) {
                    $isAvailable = false;
                    break;
                }
            }
            $availability[$currentDate->format('Y-m-d')] = $isAvailable;
            $currentDate->addDay();
        }

        return response()->json($availability);
    }
}
