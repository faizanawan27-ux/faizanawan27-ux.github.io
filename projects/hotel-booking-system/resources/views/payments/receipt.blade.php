{{-- resources/views/payments/receipt.blade.php --}}
@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Payment Receipt</div>
                <div class="card-body">
                    <h4 class="mb-4">Thank you for your payment!</h4>

                    <div class="row mb-4">
                        <div class="col-md-6">
                            <p><strong>Booking Reference:</strong> {{ $booking->booking_id }}</p>
                            <p><strong>Room:</strong> {{ $booking->room->room_type }} ({{ $booking->room->room_id }})</p>
                            <p><strong>Dates:</strong>
                                {{ $booking->check_in_date->format('M j, Y') }} to
                                {{ $booking->check_out_date->format('M j, Y') }}
                            </p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Payment Date:</strong> {{ $payment->payment_date->format('M j, Y H:i') }}</p>
                            <p><strong>Payment Method:</strong> {{ ucfirst(str_replace('_', ' ', $payment->payment_method)) }}</p>
                            <p><strong>Transaction ID:</strong> {{ $payment->transaction_id }}</p>
                        </div>
                    </div>

                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Description</th>
                                <th class="text-right">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Room Charge ({{ $booking->nights() }} nights)</td>
                                <td class="text-right">${{ number_format($booking->room_charge, 2) }}</td>
                            </tr>
                            @foreach($booking->services as $service)
                            <tr>
                                <td>{{ $service->service_name }}</td>
                                <td class="text-right">${{ number_format($service->price, 2) }}</td>
                            </tr>
                            @endforeach
                            <tr>
                                <td><strong>Total</strong></td>
                                <td class="text-right"><strong>${{ number_format($payment->amount, 2) }}</strong></td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="mt-4">
                        <a href="{{ route('bookings.show', $booking) }}" class="btn btn-primary">
                            View Booking Details
                        </a>
                        <a href="{{ $payment->receipt_url }}" target="_blank" class="btn btn-secondary">
                            Download Receipt
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
