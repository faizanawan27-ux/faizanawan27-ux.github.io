{{-- resources/views/bookings/create.blade.php --}}
@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Book Room {{ $room->room_id }} - {{ $room->room_type }}</h2>
    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body">
                    <form method="POST" action="{{ route('bookings.store') }}">
                        @csrf
                        <input type="hidden" name="room_id" value="{{ $room->room_id }}">

                        <div class="form-group">
                            <label for="check_in_date">Check-in Date</label>
                            <input type="date" class="form-control" name="check_in_date"
                                   id="check_in_date" required min="{{ date('Y-m-d') }}">
                        </div>

                        <div class="form-group">
                            <label for="check_out_date">Check-out Date</label>
                            <input type="date" class="form-control" name="check_out_date"
                                   id="check_out_date" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label for="adults">Adults</label>
                                <select class="form-control" name="adults" id="adults">
                                    @for($i = 1; $i <= $room->roomType->capacity; $i++)
                                        <option value="{{ $i }}">{{ $i }}</option>
                                    @endfor
                                </select>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="children">Children</label>
                                <select class="form-control" name="children" id="children">
                                    @for($i = 0; $i <= 4; $i++)
                                        <option value="{{ $i }}">{{ $i }}</option>
                                    @endfor
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="special_requests">Special Requests</label>
                            <textarea class="form-control" name="special_requests"
                                      id="special_requests" rows="3"></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary">Confirm Booking</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Room Details</h5>
                    <p class="card-text">
                        <strong>Type:</strong> {{ $room->room_type }}<br>
                        <strong>Capacity:</strong> {{ $room->roomType->capacity }} adults<br>
                        <strong>Amenities:</strong> {{ $room->roomType->description }}
                    </p>
                    <div id="price-calculation">
                        <p>Price will be calculated after selecting dates</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const checkIn = document.getElementById('check_in_date');
    const checkOut = document.getElementById('check_out_date');

    function calculatePrice() {
        if (checkIn.value && checkOut.value) {
            const checkInDate = new Date(checkIn.value);
            const checkOutDate = new Date(checkOut.value);
            if (checkOutDate > checkInDate) {
                const nights = Math.round((checkOutDate - checkInDate) / (1000 * 60 * 60 * 24));
                const pricePerNight = {{ $room->roomType->base_price }};
                const total = nights * pricePerNight;
                document.getElementById('price-calculation').innerHTML = `
                    <p><strong>Price Breakdown:</strong></p>
                    <p>${nights} nights x $${pricePerNight} = $${total}</p>
                    <p><strong>Total: $${total}</strong></p>
                `;
            }
        }
    }

    checkIn.addEventListener('change', calculatePrice);
    checkOut.addEventListener('change', calculatePrice);
});
</script>
@endsection
