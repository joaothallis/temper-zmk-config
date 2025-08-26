#!/bin/bash

# Build script for Temper ZMK firmware
# Usage: ./build.sh [left|right|both]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default to building both if no argument provided
TARGET="${1:-both}"

build_left() {
    echo -e "${YELLOW}Building left half...${NC}"
    nix-shell shell.nix --run "west build -s zmk/app -b nice_nano_v2 -d build/left -- -DSHIELD=temper_left -DZMK_CONFIG=$(pwd)"
    echo -e "${GREEN}✓ Left half built successfully${NC}"
}

build_right() {
    echo -e "${YELLOW}Building right half...${NC}"
    nix-shell shell.nix --run "export CMAKE_PREFIX_PATH=\$CMAKE_PREFIX_PATH:$(pwd)/zephyr/share/zephyr-package/cmake && export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb && export GNUARMEMB_TOOLCHAIN_PATH=/nix/store/dlv9q5lhqqwb7vhmc4bk9wj2yrqqwyvm-gcc-arm-embedded-14.3.rel1 && export CC=/nix/store/dlv9q5lhqqwb7vhmc4bk9wj2yrqqwyvm-gcc-arm-embedded-14.3.rel1/bin/arm-none-eabi-gcc && west build -s zmk/app -b nice_nano_v2 -d build/right -- -DSHIELD=temper_right -DZMK_CONFIG=$(pwd)"
    echo -e "${GREEN}✓ Right half built successfully${NC}"
}

case "$TARGET" in
    left)
        build_left
        echo -e "${GREEN}Build complete! Flash with: ./flash_keyboard build/left/zephyr/zmk.uf2 left${NC}"
        ;;
    right)
        build_right
        echo -e "${GREEN}Build complete! Flash with: ./flash_keyboard build/right/zephyr/zmk.uf2 right${NC}"
        ;;
    both)
        build_left
        build_right
        echo -e "${GREEN}Both halves built successfully!${NC}"
        echo -e "Flash with:"
        echo -e "  ./flash_keyboard build/left/zephyr/zmk.uf2 left"
        echo -e "  ./flash_keyboard build/right/zephyr/zmk.uf2 right"
        ;;
    *)
        echo -e "${RED}Invalid target: $TARGET${NC}"
        echo "Usage: $0 [left|right|both]"
        exit 1
        ;;
esac