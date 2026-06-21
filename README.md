# aws-signing-helper (arm64 / ARMv8.0)

Hermetic Bazel build of [`aws_signing_helper`](https://github.com/aws/rolesanywhere-credential-helper) v1.8.4
for **linux/arm64** (ARMv8.0-a, Pi-class compatible).

## Why this exists

The official AWS image (`public.ecr.aws/rolesanywhere/credential-helper`) is built on Amazon Linux
with a glibc that requires **ARMv8.2-a or newer** (Graviton2+). On Pi-class arm64 nodes (ARMv8.0)
it crashes at startup:

```
Fatal glibc error: This version of Amazon Linux requires a newer ARM64 processor
compliant with at least ARM architecture 8.2-a
```

This repo cross-compiles the binary on amd64 using **zig cc** (via `hermetic_cc_toolchain`)
targeting `aarch64-linux-gnu.2.28` — ensuring glibc 2.28+ compatibility and **no ARMv8.2-a
instructions**. The container image uses `debian:12-slim` (glibc 2.36) as the base.

## Image

```
ghcr.io/bpalermo/aws-signing-helper:latest
```

After the first CI push, make the GHCR package public in your GitHub account:
**GitHub → Packages → aws-signing-helper → Package settings → Change visibility → Public**

## Build

```bash
# Build the arm64 binary locally (requires amd64 host)
bazel build --config=cross-arm64 //:aws_signing_helper

# Build the OCI image (build only, no push)
bazel build --config=cross-arm64 //:image

# Push to ghcr.io (requires docker login to ghcr.io)
bazel run --config=cross-arm64 //:push
```

## Architecture

| Component | Choice | Reason |
|-----------|--------|--------|
| Build system | Bazel 9.1.1 + bzlmod | Hermetic, reproducible |
| Go SDK | 1.26.4 (hermetic) | Matches upstream go.mod |
| CC toolchain | `hermetic_cc_toolchain` (zig 0.12) | Hermetic CGO cross-compile |
| glibc target | 2.28 (`aarch64-linux-gnu.2.28`) | ARMv8.0 compatible, Pi-safe |
| Base image | `debian:12-slim` (arm64) | glibc 2.36, ca-certs, libdl |
| CGO need | `-ldl` only (miekg/pkcs11) | Standard glibc, no libltdl |
| Run as | uid 65532 (nonroot) | Least privilege |

## Source

Upstream source copied from `github.com/aws/rolesanywhere-credential-helper` at tag `v1.8.4`.
