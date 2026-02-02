# ledger-dist

Official distribution repository for CodeAtlas **ledger** CLI.

## Quick Install

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/mauricecarrier7/ledger-dist/main/install.sh | bash
```

### With specific version

```bash
curl -fsSL https://raw.githubusercontent.com/mauricecarrier7/ledger-dist/main/install.sh | bash -s -- --version 0.8.2
```

### Custom install directory

```bash
curl -fsSL https://raw.githubusercontent.com/mauricecarrier7/ledger-dist/main/install.sh | bash -s -- --dir ./tools/bin
```

## Manual Installation

If you prefer not to pipe to bash:

```bash
# Download
curl -fsSL -o ledger https://github.com/mauricecarrier7/ledger-dist/releases/download/v0.8.2/ledger-macos-arm64

# IMPORTANT: Clear macOS quarantine (prevents hanging)
xattr -cr ledger

# Make executable
chmod +x ledger

# Move to PATH
sudo mv ledger /usr/local/bin/
```

## Version Pinning (CI/CD)

**Always pin to a specific version in CI/CD pipelines.**

```yaml
# .github/workflows/analyze.yml
jobs:
  analyze:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install ledger
        run: |
          curl -fsSL https://raw.githubusercontent.com/mauricecarrier7/ledger-dist/main/install.sh | bash -s -- --version 0.8.2 --dir ./tools/bin
          
      - name: Run analysis
        run: ./tools/bin/ledger observe --domains arch,a11y,qa
```

## Available Platforms

| Platform | Architecture | Artifact |
|----------|--------------|----------|
| macOS | arm64 (Apple Silicon) | `ledger-macos-arm64` |

## Troubleshooting

### Binary hangs on execution (macOS)

**Symptom:** Running `ledger --version` hangs indefinitely.

**Cause:** macOS quarantine/provenance extended attributes block unsigned binaries.

**Solution:**
```bash
# Clear quarantine attributes
xattr -cr /path/to/ledger

# Or use the install script which handles this automatically
```

### "Operation not permitted" errors

```bash
# Remove all extended attributes
xattr -cr ledger

# If that fails, check if file is on a restricted volume
```

### Checksum verification failed

The install script verifies SHA256 checksums. If verification fails:

1. Retry the download (network issue)
2. Check for proxy/firewall interference
3. Report to maintainers if persistent

## Version Manifest

The `versions.json` file contains all available versions with checksums:

```json
{
  "latest": "0.8.2",
  "versions": [
    {
      "version": "0.8.2",
      "artifacts": {
        "macos-arm64": {
          "url": "https://github.com/.../ledger-macos-arm64",
          "sha256": "b40283d1e5bec356c7369b5167ad4e4ad980877295d4f5dea793cde4edc51826"
        }
      }
    }
  ]
}
```

## Source Repository

Built from: https://github.com/mauricecarrier7/CodeAtlas

## License

Same license as CodeAtlas source repository.
