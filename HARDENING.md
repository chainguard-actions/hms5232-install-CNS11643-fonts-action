<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **hms5232--install-CNS11643-fonts-action/v1.1.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions into shell commands (sub-rule a). Most critically, line 25 interpolates ${{ inputs.download-flag }} — an attacker-controlled input — directly into the shell command: `${{ github.action_path }}/download.sh -f "${{ inputs.download-flag }}"`. A malicious caller can supply a value like `-nv; malicious-command` to achieve arbitrary command execution. Additionally, every step uses ${{ github.action_path }} directly in run: blocks, which is also a ${{ }} expression interpolated into shell. All these should be moved to env: variables and referenced as quoted shell variables (e.g., "$INPUT_DOWNLOAD_FLAG" and "$GITHUB_ACTION_PATH").

Locations:

- `action.yml:22`
- `action.yml:25`
- `action.yml:29`
- `action.yml:32`
- `action.yml:35`
- `action.yml:38`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection

**Notes:**

Fixed all ${{ }} expression interpolations in run: blocks in action.yml. Moved ${{ github.action_path }} to ACTION_PATH env var and ${{ inputs.download-flag }} to INPUT_DOWNLOAD_FLAG env var in each step's env: block. All shell commands now reference these as quoted environment variables ($ACTION_PATH and $INPUT_DOWNLOAD_FLAG) instead of directly interpolating GitHub Actions expressions, preventing script injection attacks.

