import librosa
import sys
import json
import os
import unicodedata
import numpy as np

# Longitud máxima en columnas para espectrogramas
MAX_COLUMNS = 20000

def normalize_path(file_path):
  return unicodedata.normalize('NFC', file_path)

def pad_or_trim_spectrogram(spectrogram, max_columns):
  """
  Ajusta el número de columnas del espectrograma para que coincida con max_columns.
  - Si es más corto, rellena con ceros.
  - Si es más largo, lo recorta.
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
  file_path = normalize_path(file_path)
  file_path = os.path.abspath(file_path)
  y, sr = librosa.load(file_path)
  
  # Generar espectrograma mel
  mel_spectrogram = librosa.feature.melspectrogram(y=y, sr=sr)
  
  # Ajustar espectrograma a la longitud máxima
  mel_spectrogram = pad_or_trim_spectrogram(mel_spectrogram, MAX_COLUMNS)
  mel_spectrogram = librosa.util.normalize(mel_spectrogram)
  
  features = {
    'mel_spectrogram': mel_spectrogram.tolist(),
    'tempo': librosa.beat.tempo(y=y, sr=sr)[0],
  }
  return features

if __name__ == "__main__":
  file_path = sys.argv[1]
  file_path = normalize_path(file_path)
  try:
    features = extract_features(file_path)
    print(json.dumps(features))
  except Exception as err:
    print(f"Error procesando el archivo: {err}", file=sys.stderr)
    sys.exit(1)
