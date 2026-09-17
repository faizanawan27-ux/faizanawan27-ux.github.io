{{-- resources/views/rooms/availability.blade.php --}}
@extends('layouts.app')

@section('content')
<h2>Room Availability</h2>
<form method="GET" action="{{ route('rooms.availability') }}">
    <input type="date" name="check_in" required>
    <input type="date" name="check_out" required>
    <button type="submit">Check Availability</button>
</form>

@isset($availableRooms)
<table>
    <thead>
        <tr>
            <th>Room Number</th>
            <th>Type</th>
            <th>Capacity</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody>
        @foreach($availableRooms as $room)
        <tr>
            <td>{{ $room->room_id }}</td>
            <td>{{ $room->room_type }}</td>
            <td>{{ $room->roomType->capacity }}</td>
            <td>
                <a href="{{ route('bookings.create', ['room' => $room->room_id]) }}">
                    Book Now
                </a>
            </td>
        </tr>
        @endforeach
    </tbody>
</table>
@endisset
@endsection
