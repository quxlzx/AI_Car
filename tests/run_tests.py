"""Compile the actual PDE tabs against Processing and run headless tests.
No third-party Python packages needed. Provide a local Processing core JAR.
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--core', required=True, type=Path, help='Processing 4 core/library/core.jar')
parser.add_argument('--ecj', type=Path, help='Optional Eclipse Java compiler JAR when javac is unavailable')
parser.add_argument('--render', type=Path, help='Optional PNG of the actual sketch frame')
args = parser.parse_args()
core = args.core.resolve()
if not core.is_file():
    parser.error('Processing core JAR does not exist')
root = Path(__file__).resolve().parents[1]
tabs = ['AI_Car.pde', 'Brain.pde', 'Car.pde', 'checkForWall.pde', 'map.pde', 'population.pde']
with tempfile.TemporaryDirectory(prefix='ai-car-test-') as folder:
    build = Path(folder)
    java = build / 'AICar.java'
    java.write_text('import processing.core.*;\nimport java.util.*;\npublic class AICar extends PApplet {\n' +
                    '\n'.join((root / name).read_text(encoding='utf-8') for name in tabs) + '\n}', encoding='utf-8')
    sources = [str(java), str(root / 'tests/SimulationTest.java'), str(root / 'tests/RenderTest.java')]
    if args.ecj:
        compiler = ['java', '-jar', str(args.ecj.resolve()), '-17', '-nowarn']
    elif shutil.which('javac'):
        compiler = ['javac', '--release', '17']
    else:
        parser.error('Install a Java 17+ JDK or provide --ecj compiler.jar')
    subprocess.run(compiler + ['-encoding', 'UTF-8', '-cp', str(core), '-d', str(build)] + sources, check=True)
    runtime = ['java', '-Djava.awt.headless=true', '-cp', os.pathsep.join([str(core), str(build)])]
    subprocess.run(runtime + ['SimulationTest', str(root / 'data/RaceTrack5.png')], check=True)
    if args.render:
        args.render.resolve().parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(runtime + ['RenderTest', str(root / 'data'), str(args.render.resolve())], check=True)
