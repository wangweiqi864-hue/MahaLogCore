# MahaLogCore

`MahaLogCore` is a small wrapper around `SwiftyBeaver` used by the app for console and file logging. It exposes the public `MahaLog` API.

## Structure

- `MahaLogCore/Classes/MahaLog.swift`: logging entrypoint
- `MahaLogCore.podspec`: pod definition for private distribution
- `LICENSE`: inherited license file from the current source

## Current Behavior

- Writes logs to the Xcode console
- Writes rolling log files into the app sandbox
- Exposes static methods: `recordDebug`, `recordInfo`, `recordError`, `record`

## Installation

This repository is prepared for private pod distribution through:

- Pod source repo: `https://github.com/wangweiqi864-hue/MaHaSpecs.git`
- Library repo: `https://github.com/wangweiqi864-hue/MahaLogCore.git`

## Publish Checklist

- Push the repository and tag `0.1.0`
- Add the podspec to `MaHaSpecs`

## Notes

- This repository is prepared from the app's existing LocalPods logging source
- The original app integration is intentionally untouched at this stage

## License

See `LICENSE`.
