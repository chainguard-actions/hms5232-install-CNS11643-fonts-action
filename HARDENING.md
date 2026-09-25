<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate GitHub Actions expressions inside shell command strings (rule a). This means the YAML template engine substitutes the value before the shell ever sees it, enabling script injection.

1. Line 25: `run: ${{ github.action_path }}/init.sh` — `${{ github.action_path }}` interpolated directly in a run: command.
2. Line 36: `${{ github.action_path }}/download_kai.sh -f "${{ inputs.download-flag }}"` — both `github.action_path` and the attacker-controlled `inputs.download-flag` are interpolated directly. A caller can supply a value like `; malicious-command #` to inject arbitrary shell commands.
3. Line 51: `${{ github.action_path }}/download_sung.sh -f "${{ inputs.download-flag }}"` — same issue for the Sung fonts step.
4. Line 59: `${{ github.action_path }}/install.sh` — `github.action_path` interpolated directly.
5. Line 62: `run: ${{ github.action_path }}/clear.sh` — `github.action_path` interpolated directly.

Fix: Move expressions into `env:` variables and reference those shell variables (properly quoted) in the `run:` script instead of using `${{ }}` directly inside the shell command string.

Locations:

- `action.yml:25`
- `action.yml:36`
- `action.yml:51`
- `action.yml:59`
- `action.yml:62`

### unpinned-uses (severity: high)

Four `uses:` references in action.yml pin to a mutable version tag (`@v5`) rather than an immutable 40-character commit SHA. If the upstream repository is compromised or the tag is moved, the action will silently execute different code.

Failing references:
- `actions/cache/restore@v5` (Kai fonts step, line 30)
- `actions/cache/save@v5` (Kai fonts step, line 41)
- `actions/cache/restore@v5` (Sung fonts step, line 45)
- `actions/cache/save@v5` (Sung fonts step, line 54)

Fix: Pin each reference to a full 40-character commit SHA, e.g. `actions/cache/restore@1bd1e32a3bdc45362d1e726936510720a7c6158d # v5`.

Locations:

- `action.yml:30`
- `action.yml:41`
- `action.yml:45`
- `action.yml:54`

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

Fixed all findings in action.yml:
1. script-injection / static-inline-injection: Moved all ${{ github.action_path }} and ${{ inputs.download-flag }} expressions out of run: shell strings into env: blocks (ACTION_PATH and DOWNLOAD_FLAG), referenced as properly double-quoted shell variables in the run scripts.
2. unpinned-uses: Pinned all four actions/cache/restore@v5 and actions/cache/save@v5 references to their full SHA caa296126883cff596d87d8935842f9db880ef25 with # v5 comment.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted `${flags}` expansion in both `download_kai.sh` and `download_sung.sh` (line 14 in each). The `flags` variable, populated from the user-controlled `inputs.download-flag` input via getopts, was expanded unquoted in the `wget` command, allowing shell metacharacter injection. The fix tokenizes the flags string into a bash array using xargs (with a `[ -n "${flags}" ]` guard to prevent empty-input issues), then expands it as `"${wget_flags[@]}"` so each token is a separate, properly-quoted argument. This prevents injection of `;`, `|`, `$(...)`, etc. while preserving support for multiple wget flags (e.g., `-nv --timeout=30`).

