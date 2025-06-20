# FFT Denoising - MATLAB & Python Implementation

Proyek ini bertujuan untuk mempelajari dan menerapkan metode **Fast Fourier Transform (FFT)** dalam membersihkan sinyal dari gangguan noise. Dengan memanfaatkan analisis frekuensi, kita dapat memisahkan komponen utama sinyal dari komponen gangguan, kemudian merekonstruksi ulang sinyal yang lebih bersih. Proyek ini dibuat untuk memperkuat pemahaman tentang spektrum frekuensi, filtering berbasis FFT, serta perbedaan implementasi antara MATLAB dan Python.

## Simulasi menggunakan MATLAB

Pertama kita perlu membersihkan workspace.

```matlab
clc; clear; close all;
```

Kemudian kita membuat sinyal asli yang menggabungkan dua frekuensi, 40 Hz dan 10 Hz, pada waktu tertentu.

```matlab
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
```

![](/assets/original.png)

- `Fs` = 1000 adalah frekuensi sampling, dengan periode waktu T yang dihitung berdasarkan nilai `Fs`.
- `x_clean` adalah sinyal asli yang merupakan penjumlahan dua gelombang sinusoidal dengan frekuensi 40 Hz dan 10 Hz.

Langkah berikutnya adalah menambahkan noise acak ke sinyal asli. Noise ini akan disimulasikan dengan distribusi normal (Gaussian).

```matlab
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
```

![](/assets/noise.png)

- `load('noise_data.txt')` digunakan untuk memuat noise yang telah disimpan dalam file noise_data.txt. Tindakan ini diperlukan agar noise yang akan dipakai pada implementasi python serupa.
- Noise kemudian ditambahkan ke sinyal asli, menghasilkan sinyal yang terkontaminasi noise (`x_noisy`).

Kemudian melakukan Transformasi Fourier pada sinyal tercemar. Transformasi Fourier digunakan untuk memecah sinyal menjadi komponen frekuensinya. Di sini kita akan menghitung FFT (Fast Fourier Transform) dari sinyal yang terkontaminasi noise.

Secara matematis, Discrete Fourier Transform (DFT) didefinisikan sebagai:

![](/assets/rumus1.png)

Karena DFT menghitung seluruh nilai ini untuk setiap k, maka prosesnya komputasional berat. Oleh karena itu, digunakan Fast Fourier Transform (FFT) sebagai algoritma efisien untuk menghitung DFT.

FFT menghasilkan vektor kompleks, yang menunjukkan amplitudo dan fase dari setiap komponen frekuensi. Untuk keperluan analisis spektrum, kita hanya menggunakan magnitudo (dengan fungsi `abs()`).

```matlab
% --- Transformasi Fourier sinyal noisy ---
X = fft(x_noisy);

% Buat vektor frekuensi (untuk spektrum 1 sisi)
f = Fs * (0:(L/2)) / L;

% Spektrum sebelum filtering
P2 = abs(X / L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2 * P1(2:end-1);
```

Setelah memperoleh sinyal tercemar `x_noisy`, kita lakukan Fast Fourier Transform (FFT) menggunakan `X = fft(x_noisy)`; untuk mengubah sinyal dari domain waktu ke frekuensi. Karena sinyal bersifat real, spektrumnya simetris, sehingga cukup dianalisis setengahnya saja melalui vektor frekuensi `f = Fs * (0:(L/2)) / L;`. Selanjutnya dihitung spektrum amplitudo ter-normalisasi dengan `P2 = abs(X / L);`, lalu diambil satu sisi spektrum `P1 = P2(1:L/2+1);`. Nilai tengah dikalikan dua (`P1(2:end-1) = 2 * P1(2:end-1);`) untuk mengkompensasi sisi spektrum yang dibuang. Rumus akhirnya:

![](/assets/rumus2.png)

Kita juga melakukan Transfomasi Fourier pada sinyal asli untuk pembanding.

```matlab
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
```

![](/assets/spektrum.png)

Kita menghitung spektrum frekuensi dengan memanfaatkan Power Spectrum Density (PSD) untuk memvisualisasikan komponen frekuensinya.

Langkah selanjutnya yaitu filtering degan Low-pass Filter. Dalam langkah ini, kita akan menggunakan low-pass filter untuk menghapus komponen frekuensi tinggi yang merupakan noise. Kita memfilter frekuensi yang lebih tinggi dari 20 Hz (cutoff).

```matlab
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
```

![](/assets/filtering.png)

- Frekuensi yang lebih tinggi dari 20 Hz dihapus dari FFT dengan mensetkan nilai-nilai tersebut menjadi 0, yang akan mengurangi noise.
- Kemudian, kita plot kembali spektrum sinyal yang sudah difilter.

Langkah terakhir adalah Inverse Fourier Transform untuk mengembalikan sinyal yang sudah difilter ke domain waktu.

![](/assets/output.png)

- ifft(X_filtered) mengembalikan sinyal yang telah difilter ke domain waktu.

Berikut plot kesimpulan dari sinyal asli ke hasil akhir.

```matlab
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

```

![](/assets/conclusion.png)

## Simulasi dengan Python

Implementasi pada Python mengikuti langkah-langkah yang serupa dengan versi MATLAB sebelumnya. Berikut adalah kode lengkapnya.

> Code python sudah [terlampir](/fft.py)

Penjelasan library pada code python:

`numpy`: Digunakan untuk komputasi numerik berbasis array. Fungsi-fungsi utamanya dalam kode ini meliputi:

- `np.arange()` → Membuat vektor waktu.
- `np.sin(), np.cos()` → Menghasilkan sinyal sinusoidal.
- `np.fft.fft()` → Melakukan Fast Fourier Transform (FFT).
- `np.fft.fftfreq()` → Menghasilkan vektor frekuensi dari hasil FFT.
- `np.fft.ifft()` → Melakukan Inverse FFT.
- `np.loadtxt()` → Membaca data noise dari file .txt.

`matplotlib.pyplot`: Digunakan untuk membuat grafik visualisasi. Dalam kode ini, digunakan untuk:

- Membuat tiga subplot yang menunjukkan: sinyal asli, sinyal noisy, dan sinyal hasil.
- Memberi label sumbu, judul, dan tampilan grafik yang rapi.

Berikut hasil output pada file python diatas.

![](/assets/pyoutput.png)