https://github.com/tchris-lab/MirrorMate/releases

# MirrorMate — Fast Mirror Switcher for Linux, macOS, WSL 🚀🪞

[![Release](https://img.shields.io/badge/Release-%20Latest-brightgreen)](https://github.com/tchris-lab/MirrorMate/releases) [![Bash](https://img.shields.io/badge/Language-Bash-orange)](https://www.gnu.org/software/bash/) [![Topics](https://img.shields.io/badge/topics-bash%2C%20bash--tool%2C%20mirror-blue)](https://github.com/topics/mirror)

Hero image:  
![Terminal mirrors](https://images.unsplash.com/photo-1515879218367-8466d910aaa4?ixlib=rb-4.0.3&w=1200&q=80)

MirrorMate helps you switch package mirrors without fuss. It finds the fastest open-source mirrors, applies safe changes to your package sources, and offers rollback. It supports Debian/Ubuntu apt, Arch pacman, Fedora dnf/yum, and generic mirror lists.

Badges, docs, and release builds live on the Releases page: https://github.com/tchris-lab/MirrorMate/releases

Why MirrorMate
- Save time when a default mirror slows installs.
- Reduce downtime by failing over to a faster mirror.
- Keep a backup of original config files.
- Work offline with cached mirror lists.

Key features
- Mirror discovery: probes public mirrors and ranks by latency and throughput.
- Safe apply: writes to source files with an atomic swap and backup.
- Dry-run mode: shows diff before change.
- Auto-detect: detects package manager and OS.
- Interactive mode: pick mirrors from a menu.
- Scriptable mode: run in CI or automation with flags.
- Health checks: verify mirror integrity and packages.
- Rollback: revert to previous source list in one command.

Supported platforms
- Debian, Ubuntu and derivatives (apt)
- Arch, Manjaro (pacman)
- Fedora, CentOS, RHEL (dnf/yum)
- macOS Homebrew (mirror lists)
- WSL distributions
- Generic HTTP/FTP mirror lists

Quick start

1) Visit the Releases page and download the installer from there:
   https://github.com/tchris-lab/MirrorMate/releases
   The installer file named mirror-mate.sh is available as an asset. Download that file and execute it on the target machine.

2) Run the installer (example):
```bash
# download the release asset (replace version if needed)
curl -LO https://github.com/tchris-lab/MirrorMate/releases/download/v1.0.0/mirror-mate.sh
chmod +x mirror-mate.sh
sudo ./mirror-mate.sh install
```

3) Probe and apply fastest mirrors:
```bash
# probe mirrors and show a ranked list
sudo mirror-mate probe

# apply the top mirror after review
sudo mirror-mate apply --interactive
```

If you have the release page open in a browser you can also download mirror-mate.sh from the Releases page and run it that way:
https://github.com/tchris-lab/MirrorMate/releases

Install modes
- install: places the mirror-mate binary into /usr/local/bin and adds man pages.
- portable: run the script without install for temporary use.
- docker: run mirror-mate inside a container for CI jobs.

Commands (examples)
- mirror-mate probe --limit 10
  - Probe candidate mirrors, show latency and throughput.
- mirror-mate apply --distro ubuntu --mirror https://mirror.example.com
  - Apply a specific mirror URL for the detected distro.
- mirror-mate dry-run --manager apt
  - Show changes without writing files.
- mirror-mate rollback
  - Restore the previous source file from the backups directory.
- mirror-mate list --all
  - List known mirrors for a given distro.
- mirror-mate status
  - Show current active mirror and last probe result.

Safe behavior
- MirrorMate writes backups to /var/backups/mirrormate or $HOME/.mirrormate/backups.
- MirrorMate performs an atomic write: it writes a temp file and moves it into place.
- MirrorMate verifies checksum of released mirror lists before applying.
- MirrorMate offers an undo command that restores the last backup.

Configuration
MirrorMate uses a small YAML config file at /etc/mirrormate/config.yml or $HOME/.mirrormate/config.yml.

Example config:
```yaml
providers:
  - name: ubuntu
    endpoints:
      - https://mirror1.example.com/ubuntu
      - https://mirror2.example.com/ubuntu
probe:
  count: 5
  timeout: 3
apply:
  backup_dir: /var/backups/mirrormate
  dry_run: false
```

You can override single settings from the command line:
```bash
mirror-mate apply --backup-dir ~/mirrors/backup --dry-run
```

Mirror discovery method
1. Start from a provider list maintained by the community.
2. Resolve DNS and filter by geo-IP if requested.
3. Measure TCP connect latency and TLS handshake.
4. Fetch a small test file to estimate throughput.
5. Score mirrors and present results.

Common use cases
- Laptop switching networks: pick the nearest mirror based on ping.
- CI runners: set a fast mirror for package installs and revert after the run.
- Offline office: pre-select mirrors that work inside a corporate network.
- Mirror testing: add new mirrors and let MirrorMate validate integrity.

Examples

Auto detect and apply:
```bash
sudo mirror-mate auto-apply
```

Force a Fedora mirror:
```bash
sudo mirror-mate apply --distro fedora --mirror https://fedora.mirror.example.org
```

Use with Ansible (scriptable):
```yaml
- name: Ensure MirrorMate sets local mirror
  hosts: runners
  tasks:
    - name: Run MirrorMate
      shell: sudo mirror-mate apply --mirror https://mirror.local.example/arch
```

Security and integrity
- MirrorMate validates release signatures for packaged assets when present.
- MirrorMate uses HTTPS to fetch mirror lists. If a mirror uses plain HTTP, MirrorMate marks it as lower trust.
- You can add a signed manifest to the config to restrict acceptable mirrors.

Logs and troubleshooting
Logs go to /var/log/mirrormate.log or $HOME/.mirrormate/logs/mirrormate.log.

If a probe fails:
- Check network routes and firewall.
- Try a manual curl to the mirror endpoint:
  curl -I https://mirror.example.com/some-test-file
- Use `mirror-mate probe --verbose` for more context.

FAQ

Q: Does MirrorMate change package keys or repo metadata?
A: No. MirrorMate updates only the mirror base URL in your sources. It does not alter GPG keys or repo metadata. It validates file integrity by fetching index files after change.

Q: Can I create custom mirror lists?
A: Yes. Add them to $HOME/.mirrormate/custom_mirrors.yml and rerun `mirror-mate probe`.

Q: What if the new mirror lacks a package?
A: MirrorMate runs a quick integrity check for required package indexes. If the index does not match expected checksums, MirrorMate aborts the change.

Q: How do I revert?
A: Run:
```bash
sudo mirror-mate rollback
```
MirrorMate keeps a timestamped backup and restores the last valid copy.

Contributing
- Fork the repo
- Pick an open issue or open a new one for a feature or bug
- Follow the coding style in CONTRIBUTING.md (Bash script style, test functions)
- Write unit tests for probe logic where possible
- Open a pull request and reference the issue

Developer tips
- Use `mirror-mate probe --json` for machine-readable output.
- Integrate probe output with monitoring systems to detect slow mirrors.
- Use `--limit` to test only a subset of mirrors when you have bandwidth constraints.

Release & downloads
Find release assets and installer scripts on the Releases page. Download the asset named mirror-mate.sh and run it to install MirrorMate. The Releases page hosts compiled helpers and changelogs:
https://github.com/tchris-lab/MirrorMate/releases

If that link ever fails, check the Releases section on the repository page for the latest installer and assets.

Changelog highlights
- v1.0.0 — Initial stable release with probe, apply, rollback, and dry-run.
- v1.1.0 — Added pacman and dnf support, introduced JSON output for probes.
- v1.2.0 — Improved scoring algorithm and added geo-IP filtering.

Licensing
MirrorMate uses an OSI-approved license. See the LICENSE file in the repo for full terms.

Related projects and resources
- apt-mirror lists and docs
- official distro mirror lists (Ubuntu, Debian, Arch)
- netperf and iperf for bandwidth testing
- curl for fetch tests

Images and assets
- Badges use img.shields.io for live status.
- Hero image provided under free license (Unsplash).
- Iconography uses public SVGs where appropriate.

Contact and support
Open issues on GitHub for reproducible bugs and feature requests. Include distro, MirrorMate version, and the `mirror-mate probe --json` output for faster triage.

Commands reference (short)
- mirror-mate install
- mirror-mate probe [--limit N] [--json]
- mirror-mate apply [--distro NAME] [--mirror URL] [--interactive] [--dry-run]
- mirror-mate rollback
- mirror-mate status
- mirror-mate list [--all]

Files created by MirrorMate
- /usr/local/bin/mirror-mate (executable)
- /etc/mirrormate/config.yml (system config)
- /var/backups/mirrormate/* (backups)
- /var/log/mirrormate.log (logs)

Testing locally
- Run probe against a small list:
```bash
mirror-mate probe --limit 5
```
- Validate the dry run:
```bash
mirror-mate apply --dry-run --mirror https://mirror.test.example
```

Roadmap
- Add more languages and package managers.
- Add GUI for desktop environments.
- Add built-in mirror caching and pre-warming.
- Add signed manifests for mirror lists.

Keep this README as a living document. File issues for unclear steps or missing examples.