{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3Packages.west
    python3
    cmake
    ninja
    dtc
  ];

  shellHook = ''
    echo "ZMK development environment ready"
    echo "Run: west init -l config && west update && west build"
  '';
}