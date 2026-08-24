# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#        This module generates MP4 movies from sequential PNG snapshots.       #
#                                                                              #
# ============================================================================ #

import imageio
from pathlib import Path
import logging

# Silence warnings and info messages from imageio_ffmpeg
logging.getLogger("imageio_ffmpeg").setLevel(logging.ERROR)

# ============================================================================ #
#   Generate MP4 movie using imageio
# ============================================================================ #
def generate_mp4(base_dir: Path, target_keys: list, fps: int = 10):

    for key in target_keys:

        # Define the target directory containing PNGs
        img_dir = base_dir / "figures" / f"snapshots_{key}"
        if not img_dir.exists():
            continue

        # Collect all PNG files (e.g., '0.png', '100.png')
        img_paths = list(img_dir.glob("*.png"))
        if len(img_paths) == 0:
            continue
            
        # Sort files numerically based on the step number in the file name
        img_paths.sort(key=lambda x: int(x.stem))

        # Output movie file path
        movie_dir = base_dir / "figures" / "movies"
        movie_dir.mkdir(parents=True, exist_ok=True)
        movie_path = movie_dir / f"movie_{key}.mp4"

        print(f"      Generating MP4 movie for '{key}' : Progress...", end="", flush=True)

        # Initialize the imageio writer with FFmpeg backend
        # 'macro_block_size=2' forces the output dimensions to be even
        writer = imageio.get_writer(
            str(movie_path), 
            fps=fps, 
            codec="libx264", 
            quality=8,              # Video quality (1-10, default is 5)
            pixelformat="yuv420p",  # Essential for QuickTime / web playback
            macro_block_size=2      # Automatically pads odd dimensions
        )

        try:
            for img_path in img_paths:
                # Read the image
                frame = imageio.imread(str(img_path))
                
                # If the image has an alpha channel (RGBA), convert to RGB to prevent FFmpeg errors
                if frame.shape[-1] == 4:
                    frame = frame[..., :3]
                    
                # Write the frame
                writer.append_data(frame)
        finally:
            writer.close()

        print(f"\r      Generating MP4 movie for '{key}' : Completed  ")