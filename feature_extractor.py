"""
Feature Extractor para Listen My Feelings
Extrae características de audio usando librosa
Optimizado para uso en producción con mejor manejo de errores
"""

import librosa
import librosa.display
import sys
import json
import os
import unicodedata
import numpy as np
import warnings

# Suprimir advertencias de librosa
warnings.filterwarnings('ignore')

# Configuración
MAX_COLUMNS = 20000  # Longitud máxima en columnas para espectrogramas
SAMPLE_RATE = 22050  # Sample rate estándar
N_MELS = 128  # Número de bandas mel
HOP_LENGTH = 512  # Hop length para espectrograma
N_FFT = 2048  # Tamaño de la FFT

def normalize_path(file_path):
    """
    Normaliza el path del archivo para compatibilidad Unicode
    """
    return unicodedata.normalize('NFC', file_path)

def pad_or_trim_spectrogram(spectrogram, max_columns):
    """
    Ajusta el número de columnas del espectrograma para que coincida con max_columns.
    - Si es más corto, rellena con ceros.
    - Si es más largo, lo recorta.
    
    Args:
        spectrogram: Espectrograma numpy array
        max_columns: Número máximo de columnas
    
    Returns:
        Espectrograma ajustado
    """
    current_columns = spectrogram.shape[1]
    
    if current_columns < max_columns:
        # Padding: agregar ceros al final
        padding = max_columns - current_columns
        spectrogram = np.pad(spectrogram, ((0, 0), (0, padding)), mode='constant')
    elif current_columns > max_columns:
        # Trimming: recortar las columnas sobrantes
        spectrogram = spectrogram[:, :max_columns]
    
    return spectrogram

def extract_features(file_path):
    """
    Extrae características de audio de un archivo MP3/WAV
    
    Args:
        file_path: Ruta al archivo de audio
    
    Returns:
        Dict con características extraídas
    """
    file_path = normalize_path(file_path)
    file_path = os.path.abspath(file_path)
    
    # Validar que el archivo existe
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Archivo no encontrado: {file_path}")
    
    # Cargar audio
    try:
        y, sr = librosa.load(file_path, sr=SAMPLE_RATE, mono=True)
    except Exception as e:
        raise Exception(f"Error al cargar audio: {str(e)}")
    
    # Validar que el audio no está vacío
    if len(y) == 0:
        raise ValueError("El archivo de audio está vacío")
    
    # Generar espectrograma mel
    mel_spectrogram = librosa.feature.melspectrogram(
        y=y, 
        sr=sr,
        n_fft=N_FFT,
        hop_length=HOP_LENGTH,
        n_mels=N_MELS,
        fmax=8000  # Frecuencia máxima relevante para música
    )
    
    # Convertir a escala logarítmica (dB)
    mel_spectrogram_db = librosa.power_to_db(mel_spectrogram, ref=np.max)
    
    # Ajustar espectrograma a la longitud máxima
    mel_spectrogram_db = pad_or_trim_spectrogram(mel_spectrogram_db, MAX_COLUMNS)
    
    # Normalizar entre 0 y 1
    mel_spectrogram_normalized = librosa.util.normalize(mel_spectrogram_db)
    
    # Extraer tempo y beats
    try:
        tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
        # Convertir tempo a float si es array
        if isinstance(tempo, np.ndarray):
            tempo = float(tempo[0]) if len(tempo) > 0 else 120.0
        else:
            tempo = float(tempo)
    except Exception:
        tempo = 120.0  # Tempo por defecto
    
    # Extraer características adicionales
    try:
        # Centroid espectral (brillo del sonido)
        spectral_centroids = librosa.feature.spectral_centroid(y=y, sr=sr, hop_length=HOP_LENGTH)[0]
        spectral_centroid_mean = float(np.mean(spectral_centroids))
        
        # Rolloff espectral
        spectral_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr, hop_length=HOP_LENGTH)[0]
        spectral_rolloff_mean = float(np.mean(spectral_rolloff))
        
        # Zero crossing rate (indica percusividad)
        zcr = librosa.feature.zero_crossing_rate(y, hop_length=HOP_LENGTH)[0]
        zcr_mean = float(np.mean(zcr))
        
        # MFCCs (Mel-frequency cepstral coefficients)
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13, hop_length=HOP_LENGTH)
        mfcc_means = [float(np.mean(mfcc)) for mfcc in mfccs]
        
        # RMS Energy (energía/volumen)
        rms = librosa.feature.rms(y=y, hop_length=HOP_LENGTH)[0]
        rms_mean = float(np.mean(rms))
        
    except Exception as e:
        # Valores por defecto si falla la extracción
        print(f"Advertencia: No se pudieron extraer algunas características: {str(e)}", file=sys.stderr)
        spectral_centroid_mean = 0.0
        spectral_rolloff_mean = 0.0
        zcr_mean = 0.0
        mfcc_means = [0.0] * 13
        rms_mean = 0.0
    
    # Preparar características
    features = {
        'mel_spectrogram': mel_spectrogram_normalized.tolist(),
        'tempo': tempo,
        'spectral_centroid': spectral_centroid_mean,
        'spectral_rolloff': spectral_rolloff_mean,
        'zero_crossing_rate': zcr_mean,
        'mfccs': mfcc_means,
        'rms_energy': rms_mean,
        'duration': float(librosa.get_duration(y=y, sr=sr)),
        'sample_rate': sr,
        'shape': list(mel_spectrogram_normalized.shape)
    }
    
    return features

def main():
    """
    Función principal
    """
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Uso: python feature_extractor.py <ruta_archivo_audio>"}))
        sys.exit(1)
    
    file_path = sys.argv[1]
    file_path = normalize_path(file_path)
    
    try:
        features = extract_features(file_path)
        print(json.dumps(features))
        sys.exit(0)
    except FileNotFoundError as e:
        print(json.dumps({"error": str(e)}), file=sys.stderr)
        sys.exit(1)
    except Exception as err:
        print(json.dumps({"error": f"Error procesando el archivo: {str(err)}"}), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

