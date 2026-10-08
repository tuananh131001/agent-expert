"""Transcribe raw 16 kHz mono s16le PCM with faster-whisper. Usage: whisper_pcm.py <pcm> <out.txt> <model>"""
import os
import sys

import numpy as np
from faster_whisper import WhisperModel

pcm, out, model = sys.argv[1], sys.argv[2], sys.argv[3]
m = WhisperModel(model, device="cpu", compute_type="int8", cpu_threads=os.cpu_count() or 2)
audio = np.fromfile(pcm, dtype=np.int16).astype(np.float32) / 32768.0
segs, _ = m.transcribe(audio, vad_filter=True, beam_size=1)
with open(out, "w") as f:
    for s in segs:
        mm, ss = divmod(int(s.start), 60)
        hh, mm = divmod(mm, 60)
        # Flush each line so progress can be checked with `tail` while it runs
        f.write(f"[{hh:d}:{mm:02d}:{ss:02d}] {s.text.strip()}\n")
        f.flush()
