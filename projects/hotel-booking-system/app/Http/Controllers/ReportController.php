<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function occupancyReport(Request $request)
    {
        $startDate = $request->input('start_date', now()->subMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->format('Y-m-d'));

        $reportData = DB::table('bookings')
            ->select(
                'rooms.room_type',
                DB::raw('COUNT(bookings.booking_id) as total_bookings'),
                DB::raw('SUM(DATEDIFF(bookings.check_out_date, bookings.check_in_date)) as total_nights'),
                DB::raw('ROUND(SUM(DATEDIFF(bookings.check_out_date, bookings.check_in_date)) /
                    (DATEDIFF(?, ?) * COUNT(DISTINCT rooms.room_id)) * 100, 2) as occupancy_rate')
            )
            ->join('rooms', 'bookings.room_id', '=', 'rooms.room_id')
            ->whereBetween('bookings.check_in_date', [$startDate, $endDate])
            ->orWhereBetween('bookings.check_out_date', [$startDate, $endDate])
            ->groupBy('rooms.room_type')
            ->setBindings([$endDate, $startDate])
            ->get();

        return view('admin.reports.occupancy', compact('reportData', 'startDate', 'endDate'));
    }

    public function financialReport(Request $request)
    {
        $startDate = $request->input('start_date', now()->subMonth()->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->format('Y-m-d'));

        $reportData = Payment::with('booking')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->where('payment_status', 'paid')
            ->orderBy('payment_date')
            ->get()
            ->groupBy(function ($item) {
                return Carbon::parse($item->payment_date)->format('Y-m-d');
            });

        $totals = [
            'room_revenue' => $reportData->sum(function ($day) {
                return $day->sum('amount');
            }),
            'service_revenue' => 0, // Would need to calculate from services
            'total_revenue' => $reportData->sum(function ($day) {
                return $day->sum('amount');
            }),
        ];

        return view('admin.reports.financial', compact('reportData', 'totals', 'startDate', 'endDate'));
    }
}
