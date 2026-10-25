#!/usr/bin/env python3
"""Package the current checkout; refuse to overwrite an existing archive."""
import json
from pathlib import Path
import sys
import zipfile

root = Path(__file__).resolve().parents[1]
info = json.loads((root / "info.json").read_text())
prefix = f"{info['name']}_{info['version']}"
output = Path(sys.argv[1]) if len(sys.argv) == 2 else root / "dist" / f"{prefix}.zip"
output.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(output, "x", zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(root.rglob("*")):
        rel = path.relative_to(root)
        if path.is_file() and (
            rel.parts[0] in {"prototypes", "scripts", "locale", "compat", "graphics"}
            or (len(rel.parts) == 1 and (path.suffix in {".lua", ".json", ".png"}
                or path.name in {"LICENSE", "CREDITS", "README.md", "FORK.md", "changelog.txt"}))
        ):
            archive.write(path, str(Path(prefix) / rel))
print(output)
