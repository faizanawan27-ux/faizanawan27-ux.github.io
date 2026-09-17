<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UserController extends Controller
{
    public function dashboard()
    {
        $user = auth()->user();

        $upcomingBookings = $user->bookings()
            ->with('room')
            ->where('check_out_date', '>=', now())
            ->orderBy('check_in_date')
            ->get();

        $pastBookings = $user->bookings()
            ->with(['room', 'review'])
            ->where('check_out_date', '<', now())
            ->orderBy('check_out_date', 'desc')
            ->get();

        return view('user.dashboard', compact('upcomingBookings', 'pastBookings'));
    }

    public function updateProfile(Request $request)
    {
        $user = auth()->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,'.$user->user_id.',user_id',
            'phone' => 'required|string|max:20',
            'address' => 'required|string|max:255',
        ]);

        $user->update($validated);

        return back()->with('success', 'Profile updated successfully');
    }
}
