# Shaman

[![Release](https://img.shields.io/github/v/release/TWinston-66/Shaman?sort=semver)](https://github.com/TWinston-66/Shaman/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6.0-F54A2A?logo=swift&logoColor=white)](#)
[![Platform](https://img.shields.io/badge/macOS-26.0%2B-black?logo=apple)](#)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Drag-and-drop based checksum tool for Apple Silicon Macs. Verify a file against an
expected digest, or generate one.

Drop files onto the window, pick an algorithm, and hit **Hash**. Switch any file to
check mode and paste the digest you expect. Shaman computes each file's digest convurrently and
tells you whether the two match. 

## Supported algorithms

| Algorithm | Digest | Notes    |
| --------- | ------ | ---------|
| SHA-256   | 256bit | Default  |
| SHA-384   | 384bit |          |
| SHA-512   | 512bit |          |
| SHA-1     | 160bit | Insecure |
| MD5       | 128bit | Insecure |

## Installation

Download the latest `.zip` from [Releases](https://github.com/TWinston-66/Shaman/releases/latest),
unzip it, and move **Shaman.app** to `/Applications`.

Release builds are ad-hoc signed but **not notarized**, so Gatekeeper blocks the first
launch. Clear the quarantine flag:

```sh
xattr -dr com.apple.quarantine /Applications/Shaman.app
```

## Building from source

Requires Xcode 26 or later.

```sh
git clone https://github.com/TWinston-66/Shaman.git
cd Shaman
open Shaman.xcodeproj
```

Or from the command line:

```sh
xcodebuild build -project Shaman.xcodeproj -scheme Shaman -configuration Release
```

The project has `DEVELOPMENT_TEAM` set to the maintainer's Apple team, so signing will
fail for anyone else. Set your own team in **Signing & Capabilities**, or build ad-hoc
signed the way CI does:

## Requirements

- macOS 26.0 or later
- Apple Silicon

## How it works

Files are read in 1 MiB chunks through `FileHandle` and streamed into
[CryptoKit](https://developer.apple.com/documentation/cryptokit), so memory use stays
flat regardless of file size. Hashing runs off the main actor with progress reported 
back per percentage point, and each file's task is cancellable.

The app is sandboxed and holds only the `user-selected.read-only` entitlement: it can
read the files you drop on it and nothing else. There is no network access.

`scripts/generate.sh` writes incompressible test files (1M through 20G) if you want to
benchmark against large inputs.

## License

[MIT](LICENSE)
