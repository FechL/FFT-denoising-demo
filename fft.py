import numpy as np
import matplotlib.pyplot as plt

# Parameter waktu
Fs = 1000  # Frekuensi sampling (Hz)
T = 1 / Fs
L = 1000   # Panjang sinyal
t = np.arange(0, L) * T  # Vektor waktu

# Sinyal asli: gabungan frekuensi 40 Hz dan 10 Hz
x_clean = np.sin(2 * np.pi * 40 * t) + np.cos(2 * np.pi * 10 * t)

# --- Muat noise dari file noise_data.txt ---
noise = np.loadtxt("noise_data.txt")  # Membaca noise dari file

# Pastikan panjang noise sama dengan panjang sinyal
if len(noise) != len(t):
    raise ValueError("Panjang noise dan sinyal tidak cocok!")

# Sinyal tercemar
x_noisy = x_clean + noise

# --- Fourier Transform ---
X = np.fft.fft(x_noisy)
f = np.fft.fftfreq(L, d=T)

# --- Filtering: Low-pass filter manual ---
cutoff = 20  # Hz
X_filtered = X.copy()
X_filtered[np.abs(f) > cutoff] = 0  # Buang frekuensi di atas cutoff

# --- Inverse FFT ---
x_filtered = np.fft.ifft(X_filtered).real

# --- Plot hasil ---
plt.figure(figsize=(12, 8))

# Plot Sinyal Asli
plt.subplot(3, 1, 1)
plt.plot(t, x_clean)
plt.title('Sinyal Asli (40 Hz + 10 Hz)')
plt.xlabel('Waktu (s)')
plt.ylabel('Amplitudo')

# Plot Sinyal dengan Noise
plt.subplot(3, 1, 2)
plt.plot(t, x_noisy)
plt.title('Sinyal dengan Noise Acak')
plt.xlabel('Waktu (s)')
plt.ylabel('Amplitudo')

# Plot Sinyal Setelah Filtering FFT
plt.subplot(3, 1, 3)
plt.plot(t, x_filtered)
plt.title('Sinyal Setelah Pembersihan dengan FFT')
plt.xlabel('Waktu (s)')
plt.ylabel('Amplitudo')

plt.tight_layout()
plt.show()