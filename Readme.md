# PHOG Copy V86

A v86 x86 emulator running a Debian Linux environment in the browser, served via Docker.

## Requirements

- Docker Desktop

## Full Build (first time)

Builds the v86 WASM/JS artifacts and the Debian disk image, then starts the server:

```
make
```

This runs the following steps in order:
1. **`docker/builder`** — builds the Ubuntu-based Docker image with Rust + Node toolchain
2. **`docker/runbuilder`** — starts the builder container
3. **`docker/build`** — compiles `v86.wasm`, `v86-fallback.wasm`, and `libv86.js` inside the container
4. **`phog/computer-debian`** — builds the i386 Debian rootfs image used by the emulator

> **Apple Silicon (ARM):** The Makefile detects `arm64` and automatically adds `--platform linux/amd64` to all Docker commands.

## Run (after build)

If artifacts are already built, just start the server:

```
make start
```

Opens at **http://localhost:8000**

## Rebuild Debian image only

```
make computer
```

## Rebuild v86 JS/WASM only

```
make dockerbuild
```

## Open a shell in the builder container

```
make exec
```
