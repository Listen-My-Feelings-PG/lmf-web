"""
Feature Extractor para Listen My Feelings
VGGish Transfer Learning - Extrae embeddings de audio usando VGGish (PyTorch)

Modos de uso:
  Batch con streaming (llamado desde Node.js):
    python feature_extractor.py --audio-dir <dir> --output-dir <dir> --songs-file <json_file>

  Archivo individual:
    python feature_extractor.py --audio-path <path> --output-path <path>

Salida:
  JSON Lines por stdout para streaming de progreso al servidor Express.
  Cada línea es un objeto JSON con un campo "type" que indica el tipo de evento.

Embeddings:
  VGGish produce embeddings de 128 dimensiones por cada ventana de ~0.96 segundos.
  Para una canción de 3 minutos, se obtienen ~187 frames → shape (187, 128).
  Se guardan como archivos .npy (numpy binary) para carga eficiente.
"""

import argparse
import json
import sys
import os
import traceback
import unicodedata
import numpy as np
import warnings

warnings.filterwarnings('ignore')

# VGGish espera audio a 16kHz mono
SAMPLE_RATE = 16000


def emit(data: dict):
    """Emite un evento JSON por stdout para streaming hacia Node.js"""
    print(json.dumps(data, ensure_ascii=False), flush=True)


def normalize_path(file_path: str) -> str:
    """Normaliza el path del archivo para compatibilidad Unicode (nombres en japonés, etc.)"""
    return unicodedata.normalize('NFC', file_path)


def load_vggish_model():
    """
    Carga el modelo VGGish usando torch.hub (harritaylor/torchvggish).
    Primera ejecución descarga el modelo (~274MB) y lo cachea en ~/.cache/torch/hub/.
    Usa CUDA si hay GPU NVIDIA disponible (RTX 4050).
    """
    import torch

    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    emit({"type": "info", "message": f"Dispositivo de cómputo: {device}"})
    emit({"type": "info", "message": "Cargando modelo VGGish..."})

    model = torch.hub.load('harritaylor/torchvggish', 'vggish')
    model.eval()

    if device == 'cuda':
        model = model.to(device)

    emit({"type": "info", "message": "Modelo VGGish cargado correctamente"})
    return model, device


def extract_features_vggish(model, audio_path: str, device: str = 'cpu') -> np.ndarray:
    """
    Extrae embeddings VGGish de un archivo de audio.

    Usamos librosa para cargar el MP3 (soundfile no soporta MP3),
    y pasamos el array de audio directamente al modelo VGGish.

    Args:
        model: Modelo VGGish cargado
        audio_path: Ruta al archivo de audio (MP3/WAV/etc.)
        device: 'cuda' o 'cpu'

    Returns:
        numpy array de shape (N, 128) donde N = número de ventanas de ~0.96s
    """
    import torch
    import librosa

    audio_path = normalize_path(audio_path)
    audio_path = os.path.abspath(audio_path)

    # Cargar audio con librosa (soporta MP3, WAV, FLAC, OGG, etc.)
    y, sr = librosa.load(audio_path, sr=SAMPLE_RATE, mono=True)

    if len(y) == 0:
        raise ValueError("El archivo de audio está vacío")

    # VGGish forward: acepta numpy array + sample rate
    embeddings = model.forward(y, sr)

    if isinstance(embeddings, torch.Tensor):
        embeddings = embeddings.detach().cpu().numpy()

    return embeddings


def process_batch(songs_file: str, audio_dir: str, output_dir: str):
    """
    Procesa un batch de canciones y emite progreso vía stdout (JSON Lines).
    Lee la lista de canciones desde un archivo JSON temporal.

    Args:
        songs_file: Ruta al archivo JSON con array de canciones [{id, fileName, featuresFile}, ...]
        audio_dir: Directorio donde están los archivos de audio
        output_dir: Directorio donde se guardarán los .npy de features
    """
    # Leer canciones desde archivo temporal
    with open(songs_file, 'r', encoding='utf-8') as f:
        songs = json.load(f)

    total = len(songs)

    if total == 0:
        emit({"type": "complete", "total": 0, "success": 0, "failed": 0, "skipped": 0})
        return

    # Cargar modelo VGGish (primera vez descarga, luego usa cache)
    try:
        model, device = load_vggish_model()
    except Exception as e:
        emit({
            "type": "fatal",
            "error": f"No se pudo cargar el modelo VGGish: {str(e)}",
            "traceback": traceback.format_exc()
        })
        sys.exit(1)

    success_count = 0
    failed_count = 0
    skipped_count = 0

    for idx, song in enumerate(songs):
        song_id = song['id']
        file_name = song['fileName']
        existing_features = song.get('featuresFile', None)
        output_file = f"features_{song_id}.npy"
        output_path = os.path.join(output_dir, output_file)
        audio_path = os.path.join(audio_dir, file_name)

        # Verificar si las features ya fueron extraídas (evitar re-extracción)
        if existing_features and os.path.exists(os.path.join(output_dir, existing_features)):
            emit({
                "type": "skip",
                "songId": song_id,
                "message": "Features ya extraídas previamente",
                "featuresFile": existing_features,
                "current": idx + 1,
                "total": total
            })
            skipped_count += 1
            continue

        # Verificar que el archivo de audio existe
        if not os.path.exists(audio_path):
            emit({
                "type": "error",
                "songId": song_id,
                "error": f"Archivo de audio no encontrado: {file_name}",
                "current": idx + 1,
                "total": total
            })
            failed_count += 1
            continue

        # Emitir progreso: iniciando extracción
        emit({
            "type": "progress",
            "songId": song_id,
            "status": "extracting",
            "fileName": file_name,
            "current": idx + 1,
            "total": total
        })

        try:
            embeddings = extract_features_vggish(model, audio_path, device)
            np.save(output_path, embeddings)

            emit({
                "type": "result",
                "songId": song_id,
                "status": "done",
                "featuresFile": output_file,
                "shape": list(embeddings.shape),
                "current": idx + 1,
                "total": total
            })
            success_count += 1

        except Exception as e:
            emit({
                "type": "error",
                "songId": song_id,
                "error": str(e),
                "traceback": traceback.format_exc(),
                "current": idx + 1,
                "total": total
            })
            failed_count += 1

    emit({
        "type": "complete",
        "total": total,
        "success": success_count,
        "failed": failed_count,
        "skipped": skipped_count
    })


def process_single(audio_path: str, output_path: str):
    """Procesa un solo archivo de audio y guarda las features."""
    audio_path = normalize_path(audio_path)

    if not os.path.exists(audio_path):
        emit({"type": "error", "error": f"Archivo no encontrado: {audio_path}"})
        sys.exit(1)

    try:
        model, device = load_vggish_model()
        embeddings = extract_features_vggish(model, audio_path, device)
        np.save(output_path, embeddings)
        emit({
            "type": "result",
            "status": "done",
            "outputPath": output_path,
            "shape": list(embeddings.shape)
        })
    except Exception as e:
        emit({
            "type": "error",
            "error": str(e),
            "traceback": traceback.format_exc()
        })
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='VGGish Feature Extractor para Listen My Feelings'
    )
    parser.add_argument('--audio-dir', type=str,
                        help='Directorio de archivos de audio')
    parser.add_argument('--output-dir', type=str,
                        help='Directorio de salida para features (.npy)')
    parser.add_argument('--songs-file', type=str,
                        help='Ruta al archivo JSON temporal con la lista de canciones')
    parser.add_argument('--audio-path', type=str,
                        help='Ruta a un solo archivo de audio (modo individual)')
    parser.add_argument('--output-path', type=str,
                        help='Ruta de salida para un solo archivo (modo individual)')

    args = parser.parse_args()

    if args.songs_file and args.audio_dir and args.output_dir:
        # Modo batch (llamado desde el servidor Express)
        os.makedirs(args.output_dir, exist_ok=True)
        process_batch(args.songs_file, args.audio_dir, args.output_dir)
    elif args.audio_path and args.output_path:
        # Modo individual
        os.makedirs(os.path.dirname(os.path.abspath(args.output_path)), exist_ok=True)
        process_single(args.audio_path, args.output_path)
    else:
        emit({"type": "error", "error": "Argumentos inválidos. Use --help para ver opciones."})
        sys.exit(1)


if __name__ == "__main__":
    main()
