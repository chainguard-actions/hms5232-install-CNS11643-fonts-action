<!-- markdownlint-disable -->

# Hardening Report: hms5232--install-CNS11643-fonts-action/v1.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **hms5232--install-CNS11643-fonts-action/v1.1.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions into shell command strings before the shell processes them (rule a). This means YAML template substitution occurs first, allowing shell metacharacters to be injected.

1. Line 22: `run: ${{ github.action_path }}/init.sh` — `${{ github.action_path }}` is interpolated directly into the shell command.
2. Line 24–26: `${{ github.action_path }}/download.sh -f "${{ inputs.download-flag }}"` — Both `github.action_path` and the attacker-controllable `inputs.download-flag` are interpolated directly. An attacker can supply a `download-flag` value containing shell metacharacters (e.g. `; malicious-command`) to achieve arbitrary command execution.
3. Line 28: `run: ${{ github.action_path }}/copy.sh kai` — `github.action_path` interpolated directly.
4. Line 31: `run: ${{ github.action_path }}/copy.sh sung` — `github.action_path` interpolated directly.
5. Line 34: `run: ${{ github.action_path }}/install.sh` — `github.action_path` interpolated directly.
6. Line 38: `run: ${{ github.action_path }}/clear.sh` — `github.action_path` interpolated directly.

The fix is to use the `$GITHUB_ACTION_PATH` environment variable instead of `${{ github.action_path }}`, and to pass `inputs.download-flag` via an `env:` block with a quoted shell variable reference (e.g. `env: DOWNLOAD_FLAG: ${{ inputs.download-flag }}` and then `"$DOWNLOAD_FLAG"` in the script).

Locations:

- `action.yml:22`
- `action.yml:24`
- `action.yml:28`
- `action.yml:31`
- `action.yml:34`
- `action.yml:38`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.download-flag }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection

**Notes:**

Fixed all script injection issues in hardened/action/action.yml:
1. Replaced all `${{ github.action_path }}` interpolations in run: blocks with the `$GITHUB_ACTION_PATH` environment variable (lines 22, 25, 28, 31, 34, 38).
2. Moved `${{ inputs.download-flag }}` out of the run: block and into an `env:` block as `DOWNLOAD_FLAG`, then referenced it as `"$DOWNLOAD_FLAG"` in the shell script to prevent shell metacharacter injection from attacker-controlled input.

