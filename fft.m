clc; clear; close all;

% --- Paramater sinyal ---
Fs = 1000;          % Frekuensi sampling
T = 1 / Fs;         % Periode sampling
L = 1000;           % Panjang sinyal
t = (0:L-1) * T;    % Vektor waktu

% Sinyal asli: gabungan frekuensi 40 Hz dan 10 Hz
x_clean = sin(2*pi*40*t) + cos(2*pi*10*t);

% Plot sinyal asli
figure(1)
plot(t, x_clean, 'r', 'LineWidth', 1);
xlabel('Waktu (s)');
ylabel('Amplitudo');

% --- Baca noise dari file Python ---
noise = load('noise_data.txt');

% Pastikan noise berbentuk baris dan ukuran cocok
if size(noise, 2) == 1
    noise = noise';  % Ubah kolom jadi baris
end
if length(noise) ~= length(t)
    error('Panjang noise dan t tidak sama!');
end

% Gabungkan sinyal + noise
x_noisy = x_clean + noise;

% Plot sinyal asli dengan sinyal terkontaminasi noise
figure(2)
plot(t, x_noisy, 'b', 'LineWidth', 1); hold on;
plot(t, x_clean, 'r', 'LineWidth', 1);
legend('Noisy', 'Clean');
ylim([-10 10]);
xlabel('Waktu (s)');
ylabel('Amplitudo');
hold off;

% --- Transformasi Fourier sinyal noisy ---
X = fft(x_noisy);

% Buat vektor frekuensi (untuk spektrum 1 sisi)
f = Fs * (0:(L/2)) / L;

% Spektrum sebelum filtering
P2 = abs(X / L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2 * P1(2:end-1);

% --- Transformasi Fourier sinyal asli ---
X_clean = fft(x_clean);

% Hitung spektrum 1 sisi
P2_clean = abs(X_clean / L);
P1_clean = P2_clean(1:L/2+1);
P1_clean(2:end-1) = 2 * P1_clean(2:end-1);

% Hitung spektrum noisy
P2_noisy = abs(X / L);
P1_noisy = P2_noisy(1:L/2+1);
P1_noisy(2:end-1) = 2 * P1_noisy(2:end-1);

% Plot spektrum sinyal asli dan noisy
figure(3)
plot(f, P1_clean, 'b', 'LineWidth', 1.5); hold on;
plot(f, P1_noisy, 'r--', 'LineWidth', 1.2);
xlabel('Frekuensi (Hz)');
ylabel('|Spektrum|');
legend('Sinyal Asli', 'Sinyal + Noise');
xlim([0 100]);
grid on;

% --- Filtering: Low-pass ---
cutoff = 20;  % Hz
X_filtered = X;
X_filtered((cutoff+1):(L-cutoff)) = 0;

% Spektrum sesudah filtering
P2f = abs(X_filtered / L);
P1f = P2f(1:L/2+1);
P1f(2:end-1) = 2 * P1f(2:end-1);

% Plot spektrum setelah filtering
figure(4)
plot(f, P1f, 'g', 'LineWidth', 1.5);
xlabel('Frekuensi (Hz)');
ylabel('|Spektrum|');
xlim([0 100]);
grid on;

% --- Inverse FFT ---
x_filtered = real(ifft(X_filtered));

% Plot sinyal setelah filtering
figure(5)
plot(t, x_filtered);
xlabel('Waktu (s)');
ylabel('Amplitudo');

% --- Plot hasil waktu ---
figure(6)
subplot(3,1,1); plot(t, x_clean);
title('Sinyal Asli (40 Hz + 10 Hz)');
xlabel('Waktu (s)');
ylabel('Amplitudo');
subplot(3,1,2); plot(t, x_noisy);
title('Sinyal + Noise dari Python');
xlabel('Waktu (s)');
ylabel('Amplitudo');
subplot(3,1,3); plot(t, x_filtered);
title('Sinyal Setelah Filtering FFT');
xlabel('Waktu (s)');
ylabel('Amplitudo');