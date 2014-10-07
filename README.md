## Synopsis

This docker image ships a minimal Haskell toolchain.

### Use Cases

This image can be used in the following ways:

*   **As a containerized Haskell development environment**

*   **As a container in which to build and run Haskell apps locally or deploy remotely**

*   **As a base image for other containers depending on the Haskell toolchain**

### Contents

The default configuration of this image provides the following packages:

| package         | version    |
|-----------------|------------|
| `alex`          | `3.1.3`    |
| `cabal-install` | `1.20.0.3` |
| `happy`         | `1.19.4`   |
| `ghc`           | `7.8.3`    |
