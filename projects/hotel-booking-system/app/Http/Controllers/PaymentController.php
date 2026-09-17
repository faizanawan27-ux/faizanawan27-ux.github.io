<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    public function create(Booking $booking)
    {
        if ($booking->payment) {
            return redirect()->route('bookings.show', $booking);
        }

        return view('payments.create', compact('booking'));
    }

    public function store(Request $request, Booking $booking)
    {
        $validated = $request->validate([
            'payment_method' => 'required|in:credit_card,debit_card,paypal,bank_transfer',
            'card_number' => 'required_if:payment_method,credit_card,debit_card',
            'expiry' => 'required_if:payment_method,credit_card,debit_card',
            'cvc' => 'required_if:payment_method,credit_card,debit_card',
        ]);

        try {
            // Process payment with Stripe/PayPal
            $payment = $this->processPayment($booking, $validated);

            // Create payment record
            Payment::create([
                'payment_id' => Str::uuid(),
                'booking_id' => $booking->booking_id,
                'payment_status' => 'paid',
                'amount' => $booking->total_amount,
                'payment_method' => $validated['payment_method'],
                'transaction_id' => $payment->id,
                'receipt_url' => $payment->receipt_url,
                'payment_date' => now(),
            ]);

            // Update booking status
            $booking->update(['booking_status' => 'confirmed']);

            return redirect()->route('bookings.show', $booking)
                ->with('success', 'Payment processed successfully!');
        } catch (\Exception $e) {
            return back()->withErrors(['payment' => $e->getMessage()]);
        }
    }

    protected function processPayment($booking, $data)
    {
        // Mock implementation — would call Stripe/PayPal in production
        return (object) [
            'id' => 'ch_'.Str::random(24),
            'receipt_url' => 'https://example.com/receipt/'.Str::random(16),
        ];
    }
}
