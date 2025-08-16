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
- Controller: nice!nano v2
- Display: 128x32 OLED (optional)
- RGB: WS2812 underglow with 10 LEDs (optional)
- Split: Left half is primary/central

### Common Tasks
- **Toggle QWERTY layer**: Defined on FUN layer
- **Bluetooth pairing**: BT_SEL commands on FUN layer
- **Clear Bluetooth**: BT_CLR on FUN layer
- **Switch USB/BT output**: OUT_TOG on FUN layer
