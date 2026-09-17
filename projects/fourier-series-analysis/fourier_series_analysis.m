% Part 1: Process registration number
registration_number = input('Enter registration number: ', 's');

% Initialize variables
numeric_portion = '';
i = 1;

% Remove alphabetic portion
while i <= length(registration_number)
    if ~isnan(str2double(registration_number(i))) % Check if character is a digit
        numeric_portion = [numeric_portion, registration_number(i)];
    end
    i = i + 1;
end

disp(['The numeric portion of the entered registration number is ', numeric_portion]);

% Part 2: Replace duplicate digits
replaced_number = numeric_portion;

% Create replacement map with arbitrary non-zero digits
unique_digits = unique(numeric_portion, 'stable');
replacement_digits = ['1','2','3','4','5','6','7','8','9']; % Arbitrary non-zero digits
replacement_map = containers.Map();

% Ensure unique replacements
for i = 1:length(unique_digits)
    replacement_map(unique_digits(i)) = replacement_digits(i);
end

% Replace duplicate digits
for i = 1:length(numeric_portion)
    replaced_number(i) = replacement_map(numeric_portion(i));
end

disp(['After replacing duplicates, the number is ', replaced_number]);

% Ensure 6 unique digits
replaced_number = replaced_number(1:6);
disp(['Six unique digits for Fourier coefficients: ', replaced_number]);

% Part 3: Fourier series coefficients and plotting
ak = zeros(1, 101); % Array to hold coefficients from -50 to 50

for k = -50:50
    if k == 0
        ak(k+51) = 10;
    elseif abs(k) <= 6
        ak(k+51) = str2double(replaced_number(abs(k))); % Use replaced digits as coefficients
    else
        ak(k+51) = 0;
    end
end

% Reconstructing the signal
M = 100; % Number of terms
T = 2 * pi; % Period
t = linspace(-T/2, T/2, 1000); % Time vector
x = zeros(size(t));

for k = -50:50
    ak_val = ak(k+51);
    x = x + ak_val * exp(1i * k * t * (2 * pi / T)); % Corrected complex exponential handling
end

% Plotting Fourier coefficients
figure;
stem(-50:50, ak);
title('Fourier Series Coefficients');
xlabel('k');
ylabel('a_k');
grid on;

% Plotting reconstructed signal
figure;
plot(t, real(x), 'LineWidth', 1.5);
title('Reconstructed Signal');
xlabel('Time');
ylabel('Amplitude');
grid on;
