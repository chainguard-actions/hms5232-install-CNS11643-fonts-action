<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in action.yml directly interpolate ${{ github.action_path }} and ${{ inputs.download-flag }} expressions inside shell command strings. Any ${{ ... }} expression interpolated directly into a run: block is a script-injection risk because YAML template substitution happens before the shell ever sees the string. Specifically: (1) Line 26: `run: ${{ github.action_path }}/init.sh` — github.action_path interpolated directly. (2) Line 37: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"` — both github.action_path and the user-controlled inputs.download-flag are interpolated directly into the shell command. (3) Line 52: `${{ github.action_path }}/download_sung.sh -f "${{ inputs.download-flag }}"` — same issue. (4) Line 61: `${{ github.action_path }}/install.sh` — github.action_path interpolated directly. (5) Line 65: `${{ github.action_path }}/clear.sh` — github.action_path interpolated directly. The inputs.download-flag value is attacker-controlled and is injected directly into the shell command string without going through an env: variable, enabling command injection.

Locations:

- `action.yml:26`
- `action.yml:37`
- `action.yml:52`
- `action.yml:61`
- `action.yml:65`

### script-injection (severity: high)

Sub-rule (b): In download_kai.sh (line 14) and download_sung.sh (line 14), the shell variable ${flags} — which holds the value of inputs.download-flag passed from action.yml — is expanded unquoted inside the wget command: `wget -O Fonts_Kai.zip ${flags} https://...` and `wget -O Fonts_Sung.zip ${flags} https://...`. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, glob chars) out of the value, enabling command injection. The variable must be double-quoted: `"${flags}"`.

Locations:

- `download_kai.sh:14`
- `download_sung.sh:14`

### unpinned-uses (severity: high)

All four uses: references in action.yml point to mutable version tags (@v5) rather than immutable full 40-character commit SHA digests. This exposes the action to supply-chain attacks: if the referenced tag is moved or the upstream repository is compromised, malicious code could be silently injected. Failing references: (1) Line 31: `uses: actions/cache/restore@v5` (2) Line 41: `uses: actions/cache/save@v5` (3) Line 46: `uses: actions/cache/restore@v5` (4) Line 56: `uses: actions/cache/save@v5`. Each should be pinned to a full SHA, e.g. `uses: actions/cache/restore@<40-char-sha> # v5`.

Locations:

- `action.yml:31`
- `action.yml:41`
- `action.yml:46`
- `action.yml:56`

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

1. action.yml - script-injection: Moved all ${{ github.action_path }} and ${{ inputs.download-flag }} expressions out of run: shell strings into env: blocks. Scripts now reference $ACTION_PATH and $DOWNLOAD_FLAG environment variables instead.

2. action.yml - unpinned-uses: Pinned all four actions/cache/restore@v5 and actions/cache/save@v5 references to full SHA caa296126883cff596d87d8935842f9db880ef25 with # v5 comments.

3. download_kai.sh and download_sung.sh - script-injection: Quoted ${flags} to "${flags}" in the wget commands to prevent shell metacharacter injection from the download-flag input value.

