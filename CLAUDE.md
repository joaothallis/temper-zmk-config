# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a ZMK firmware configuration for the Temper keyboard - a 36-key wireless split keyboard based on the Chocofi design. The repository uses GitHub Actions to automatically build firmware and generate keymap documentation.

## Build Commands

The project uses GitHub Actions for automated building. To trigger a new build:
- Push changes to the repository
- Firmware artifacts will be available in GitHub Actions runs

For local development with ZMK:
```bash
# Initialize west workspace (first time setup)
west init -l config
west update
west build -b nice_nano_v2 -d build/left -- -DSHIELD=temper_left
west build -b nice_nano_v2 -d build/right -- -DSHIELD=temper_right
```

## Architecture

### Key Files
- `boards/shields/temper/temper.keymap` - Main keymap configuration with all layers and behaviors
- `boards/shields/temper/temper.dtsi` - Hardware layout definition (36-key matrix, OLED config)
- `build.yaml` - GitHub Actions build matrix configuration
- `.github/workflows/build.yml` - Automated firmware building
- `.github/workflows/doc.yml` - Automated keymap visualization generation

### Layer Structure
The keyboard has 5 layers:
1. **DEFAULT (0)** - Colemak DHm layout with custom mod-morphs
2. **QWERTY (1)** - Standard QWERTY (toggleable)
3. **NUM (2)** - Numbers and symbols
4. **NAV (3)** - Navigation with vim-like arrows
5. **FUN (4)** - Function keys, media controls, Bluetooth management

### Advanced Features
- **Conditional Layers**: FUN layer activates when both NUM and NAV are held
- **Mod-Morph Behaviors**: Keys that change output based on modifiers (defined in keymap)
- **Smart Shift**: Double-tap shift for caps word
- **Bluetooth**: Supports 5 profiles (BT_SEL 0-4)

## Development Notes

**User Preference**: Always assume the user is using the QWERTY layer (layer 1) instead of the default Colemak layer (layer 0).

### Important: Git Push Workflow
**Always rebase before pushing!** The GitHub Actions workflow automatically creates commits after each push (for keymap visualization), which causes branch divergence. To avoid conflicts:

```bash
# Before pushing any commits:
git pull --rebase origin main
# If GPG signing fails during rebase:
git -c commit.gpgsign=false rebase --continue

# Then push your changes:
git push origin main
# Or if necessary (with caution):
git push --force-with-lease origin main
```

This is necessary because the `doc.yml` workflow commits updated keymap images after every push, creating a divergent history.

### Modifying Keymaps
When editing `temper.keymap`:
- Use ZMK keycodes (e.g., `&kp`, `&mt`, `&lt`)
- Test conditional layer logic when modifying layer activation
- The keymap visualization will auto-update via GitHub Actions

### Adding New Behaviors
Custom behaviors are defined in the keymap file's top section. Follow existing patterns for:
- Mod-morph behaviors (e.g., `bspc_del`, `smart_shft`)
- Hold-tap configurations
- Conditional layer definitions

### Hardware Configuration
- Controller: ProMicro NRF52840
- Display: None
- RGB: None
- Split: Left half is primary/central

### Firmware Update Process
1. **Build firmware**:
   
   **Local build (preferred for development)**:
   ```bash
   # Build both halves (or specify left/right)
   ./build.sh          # builds both halves
   ./build.sh left     # builds left half only
   ./build.sh right    # builds right half only
   ```
   
   **GitHub Actions build**:
   - Push changes to GitHub repository
   - GitHub Actions automatically builds firmware
   - Go to Actions tab on **joaothallis/temper-zmk-config** (NOT upstream repo)
   - Find latest successful build
   - Download firmware artifacts (contains `temper_left.uf2` and `temper_right.uf2`)

2. **Flash firmware using the script**:
   **IMPORTANT: When asked to flash firmware, always use the `flash_keyboard` script**
   
   ```bash
   # Flash from local build
   ./flash_keyboard build/left/zephyr/zmk.uf2 left
   ./flash_keyboard build/right/zephyr/zmk.uf2 right
   
   # Flash from GitHub Actions zip
   ./flash_keyboard firmware.zip left
   ./flash_keyboard firmware.zip right
   ```
   
   The script will:
   - Wait for bootloader (double-tap reset button)
   - Detect the bootloader drive automatically
   - Copy firmware and handle auto-eject
   - Provide clear status messages
   
   **Manual method (fallback only)**:
   ```bash
   # Check if bootloader is mounted
   ls /Volumes/ | grep -E 'NICENANO|NRF52BOOT'
   
   # Flash firmware (example for left half)
   cp build/left/zephyr/zmk.uf2 /Volumes/NICENANO/
   ```

3. **Verify installation**:
   - Both halves should reconnect automatically
   - Test new keybindings/features
   - If issues occur, reflash with previous working firmware

### Troubleshooting

**Only one half working after flash:**
- Check TRRS cable connection - ensure it's fully inserted and clicked in on both sides
- Try unplugging and reconnecting the TRRS cable
- Re-flash the non-working half - the flash may have failed
- Power cycle: unplug USB, wait 5 seconds, plug back in

**Bootloader not detected:**
- Try different USB cable (some are power-only)
- Try different USB port
- Use double-tap reset button (not triple-tap)
- Check toggle switches on keyboard if present

**Downloaded wrong firmware:**
- Always download from **joaothallis/temper-zmk-config** Actions tab
- NOT from upstream repo (raeedcho/temper-zmk-config)
- Use latest successful build, not older builds

**Flash appears to fail with I/O error:**
- This is normal! I/O errors during UF2 flash usually indicate success
- The drive auto-ejects when flash completes, causing the "error"
- Check if drive disappeared - this confirms successful flash

### Finding Key Locations

When asked about key locations (e.g., "where is @?"), **always read the keymap file** to provide accurate information:

```bash
# Read the keymap file to find key locations
cat boards/shields/temper/temper.keymap
```

The keymap file contains all layers:
- **default_layer** (lines 89-101): QWERTY layout (user's primary layer)
- **colemak_layer** (lines 102-114): Alternative Colemak layout
- **num_layer** (lines 115-127): Numbers and symbols - accessed by holding left thumb key
- **nav_layer** (lines 129-141): Navigation keys - accessed by holding right thumb key  
- **fun_layer** (lines 143-155): Function keys and Bluetooth - accessed by holding both NUM+NAV

To answer key location questions:
1. Read the keymap file
2. Find the key in the appropriate layer
3. Map its position to QWERTY physical locations (since user uses QWERTY)
4. Explain how to access it (which layer, which modifier key to hold)

### Drawing Keymap Visualization Locally

To generate keymap visualizations locally (useful for testing before GitHub Actions):

```bash
# 1. Parse the keymap file to YAML format
nix-shell -p python3Packages.keymap-drawer --run "keymap parse -z boards/shields/temper/temper.keymap -c 10 > keymap_img/temper.yaml"

# 2. Draw the SVG visualization using the chocofi layout
nix-shell -p python3Packages.keymap-drawer --run "keymap -c keymap_img/keymap_drawer.config.yaml draw -k chocofi keymap_img/temper.yaml > keymap_img/temper.svg"

# Alternative: Combined one-liner
nix-shell -p python3Packages.keymap-drawer --run "keymap parse -z boards/shields/temper/temper.keymap -c 10 | keymap -c keymap_img/keymap_drawer.config.yaml draw -k chocofi /dev/stdin > keymap_img/temper.svg"
```

This generates:
- `keymap_img/temper.yaml` - Parsed keymap data
- `keymap_img/temper.svg` - Visual keymap representation

### Common Tasks
- **Toggle QWERTY layer**: Defined on FUN layer
- **Bluetooth pairing**: BT_SEL commands on FUN layer
- **Clear Bluetooth**: BT_CLR on FUN layer
- **Switch USB/BT output**: OUT_TOG on FUN layer
