"""Check the built ZIP contains every tracked runtime file, including graphics."""
from pathlib import Path
import json
import subprocess
import sys
import tempfile
import zipfile

root = Path(__file__).resolve().parents[1]
info = json.loads((root / "info.json").read_text())
prefix = f"{info['name']}_{info['version']}"
with tempfile.TemporaryDirectory() as temp:
    output = Path(temp) / f"{prefix}.zip"
    subprocess.run([sys.executable, str(root / "tools/build_mod.py"), str(output)], check=True)
    files = subprocess.check_output(["git", "ls-files"], cwd=root, text=True).splitlines()
    with zipfile.ZipFile(output) as archive:
        assert archive.testzip() is None
        for name in files:
            if name.startswith((".", "tests/", "tools/")) or name.endswith(".gif"):
                continue
            assert archive.read(f"{prefix}/{name}") == (root / name).read_bytes(), name
print("PASS: all tracked runtime files are packaged")
