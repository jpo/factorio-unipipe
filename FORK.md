# Personal Unipipe fork

Fork: https://github.com/jpo/factorio-unipipe
Upstream: https://github.com/mpcomplete/factorio-unipipe
The official portal https://mods.factorio.com/mod/Unipipe confirms this source repository.
Base: `eea324093897fff1cabc51f2fec62e98919e563d`, Unipipe 1.1.0 for Factorio 2.1.

## Preserved local fixes

Recovered from the repaired ZIP produced on 2026-10-24. On 2026-10-25 the installed ZIP and yesterday's repaired ZIP had identical SHA-256: `d23f1f1ebacbc8ef82c683e3f610225ec99a5b28269ab24826a12ce75ff82d6c`.
Every file in that installed archive matches this fork after normalizing CRLF line endings. The only runtime source change against upstream is scripts/unipipe.lua:

- Safely normalize strings, filter tables, and LuaFluidPrototype objects without reading unsupported fields. Fixes `LuaFluidPrototype doesn't contain key fluid`.
- Skip missing, zero, or out-of-range fluidbox indices during deferred traversal, since recipe changes can remove fluidboxes before the scan executes.

No recipe, research, machinery, balance, or other gameplay changes are included. Unlike the separate Unichest fork, Unipipe still requires its original research. LICENSE, CREDITS, author, mod ID and version are preserved. MIT permits this fork with its copyright and permission notices retained.

## Build and install

```sh
cd ~/Code/factorio/unipipe
python3 tools/build_mod.py
```

Python 3 is the only build requirement. This creates dist/Unipipe_1.1.0.zip and refuses to overwrite an existing archive; pass a different output path as the sole argument if needed. Runtime files, including compat/, and license notices are included; test helpers are excluded.

Your installed ZIP already contains these fixes and was not modified during this fork task. For a later installation: quit Factorio completely, move the existing Unipipe ZIP to a backup folder outside mods, and place the new ZIP in `~/Library/Application Support/factorio/mods/`. Keep kry_stdlib installed. Do not load two copies of Unipipe. Restart Factorio to load changed Lua files. The mod portal can overwrite this personal build because its internal version remains 1.1.0.

## Reproduce engine regression tests

Set FACTORIO to the Factorio 2.1 executable and DATA to its game data directory. On this Mac both are beneath `~/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents` (MacOS/factorio and data).

```sh
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/mods" "$TEST_DIR/user"
cp dist/Unipipe_1.1.0.zip "$TEST_DIR/mods/"
cp "$HOME/Library/Application Support/factorio/mods/kry_stdlib_2.2.25.zip" "$TEST_DIR/mods/"
cp -R tests/unipipe-regression_0.0.1 "$TEST_DIR/mods/"
printf '[path]\nread-data=%s\nwrite-data=%s\n' "$DATA" "$TEST_DIR/user" > "$TEST_DIR/config.ini"
"$FACTORIO" --config "$TEST_DIR/config.ini" --mod-directory "$TEST_DIR/mods" --create "$TEST_DIR/test.zip"
"$FACTORIO" --config "$TEST_DIR/config.ini" --mod-directory "$TEST_DIR/mods" --benchmark "$TEST_DIR/test.zip" --benchmark-ticks 301
```

Require both exit codes to be zero and the markers UNIPIPE_DIRECT_PASS and UNIPIPE_CONNECTION_PASS. Do not install the test helper in normal gameplay.

On 2026-10-25, Factorio 2.1.23 with kry_stdlib 2.2.25 reproduced the exact fluid-prototype crash with unmodified upstream. The patched fork passed real LuaFluidPrototype normalization, string/table/nil cases, invalid fluidbox checks, and 301 ticks with 16 infinity-pipe connections around chemical plants using no recipe, sulfur, plastic, and sulfuric acid. No live save was modified. These tests do not establish every possible mod combination or multiplayer behavior.
