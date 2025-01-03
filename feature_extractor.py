import librosa
import sys
import json
import os

def extract_features(file_path):
  y, sr = librosa.load(file_path)
  features = {
  	'mel_spectrogram': librosa.feature.melspectrogram(y=y, sr=sr).tolist(),
    'tempo': librosa.beat.tempo(y=y, sr=sr)[0],
  }
  ##current_file_path = os.path.abspath(__file__)
  ##return {'current_path':current_file_path,'file_path':file_path}
  return features

if __name__ == "__main__":
  file_path = sys.argv[1]
  features = extract_features(file_path)
  print(json.dumps(features))
