import librosa
import sys
import json
import os
import unicodedata

def normalize_path(file_path):
  return unicodedata.normalize('NFC', file_path)

def extract_features(file_path):
  file_path = normalize_path(file_path)
  file_path = os.path.abspath(file_path)
  y, sr = librosa.load(file_path)
  features = {
  	'mel_spectrogram': librosa.feature.melspectrogram(y=y, sr=sr).tolist(),
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
