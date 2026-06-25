<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions inside shell command strings, violating rule (a). (1) Line 26: `run: ${{ github.action_path }}/init.sh` — github.action_path interpolated directly into the shell command. (2) Line 38: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"` — both github.action_path and the user-controlled inputs.download-flag are interpolated directly; an attacker can supply shell metacharacters in inputs.download-flag that are substituted before the shell parses the command. (3) Line 57: same pattern for download_sung.sh with inputs.download-flag. (4) Line 66: `${{ github.action_path }}/install.sh` interpolated directly. (5) Line 70: `${{ github.action_path }}/clear.sh` interpolated directly. Additionally, in download_kai.sh (line 14) and download_sung.sh (line 14), the shell variable `${flags}` (holding the value of inputs.download-flag passed via -f argument) is used unquoted in the wget invocation, violating rule (b) — unquoted expansion allows shell metacharacter injection from the caller-supplied flag value.

Locations:

- `action.yml:26`
- `action.yml:38`
- `action.yml:57`
- `action.yml:66`
- `action.yml:70`
- `download_kai.sh:14`
- `download_sung.sh:14`

### unpinned-uses (severity: high)

Four uses: references in action.yml use mutable version tags instead of pinned 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag is moved or compromised. Failing references: `actions/cache/restore@v5` (line 31), `actions/cache/save@v5` (line 43), `actions/cache/restore@v5` (line 50), `actions/cache/save@v5` (line 62). Each should be replaced with the full commit SHA, e.g. `actions/cache/restore@<40-char-sha> # v5`.

Locations:

- `action.yml:31`
- `action.yml:43`
- `action.yml:50`
- `action.yml:62`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:39`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:59`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, static-inline-injection

**Notes:**

Fixed all findings in action.yml, download_kai.sh, and download_sung.sh:
1. script-injection / static-inline-injection: Moved all ${{ github.action_path }} and ${{ inputs.download-flag }} expressions out of run: blocks into env: blocks (ACTION_PATH and DOWNLOAD_FLAG), referencing them as plain shell variables in the run scripts.
2. unpinned-uses: Pinned all four actions/cache/restore@v5 and actions/cache/save@v5 references to full commit SHA 27d5ce7f107fe9357f9df03efb73ab90386fccae # v5.
3. Quoted ${flags} as "${flags}" in the wget invocations in download_kai.sh (line 14) and download_sung.sh (line 14) to prevent shell metacharacter injection from caller-supplied flag values.

