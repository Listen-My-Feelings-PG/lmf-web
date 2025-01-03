import librosa
import sys
import json

def extract_features(file_path):
    y, sr = librosa.load(file_path)
    features = {
        'mel_spectrogram': librosa.feature.melspectrogram(y=y, sr=sr).tolist(),
        'tempo': librosa.beat.tempo(y=y, sr=sr)[0],
    }
    return features

if __name__ == "__main__":
    file_path = sys.argv[1]
    features = extract_features(file_path)
    print(json.dumps(features))
