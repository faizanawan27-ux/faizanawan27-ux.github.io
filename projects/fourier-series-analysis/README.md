# Fourier Series Analysis (Registration Number → Signal)

Signals and Systems Lab (CSE-301L) project — UET Peshawar, Spring 2024.

A MATLAB program that:
1. Takes a user-entered registration number and strips it to its numeric digits.
2. Replaces duplicate digits with arbitrary non-zero digits so the result has
   six unique digits.
3. Uses those six digits as Fourier series coefficients `a_k` (k = -50..50,
   with `a_0 = 10`), reconstructs the corresponding periodic signal, and
   plots both the coefficient spectrum and the reconstructed time-domain
   signal.

## Run
Open `fourier_series_analysis.m` in MATLAB/Octave and run it. It will prompt:
```
Enter registration number:
```
and produce two figures — the stem plot of `a_k` and the reconstructed
signal `x(t)`.

## Author
Faizan — Section B.
