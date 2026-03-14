# Dependencies Report

**Date:** 2026-03-14
**Repository:** antneymon-ops/rubygems
**Version:** 4.1.0.dev

---

## Overview

RubyGems is a core Ruby infrastructure library that manages its own dependencies carefully. This report documents the dependency health across all components.

---

## 1. RubyGems Core

RubyGems core has **no external runtime dependencies**. It is designed to be self-contained and ships as part of the Ruby standard library.

### Vendored Libraries

Located in `lib/rubygems/vendor/`:

| Library | Purpose | Update Strategy |
|---------|---------|----------------|
| Various vendored gems | Internal use | Manual review + update |

---

## 2. Bundler Component

The Bundler gem is co-located in `bundler/`. Its dependencies are defined in `bundler/bundler.gemspec`.

### Development Dependencies

Bundler's development dependencies include testing and tooling gems. These are regularly updated and tested via CI.

---

## 3. CI/CD Tool Dependencies

### GitHub Actions

All GitHub Actions are pinned to specific SHAs for security. Monthly updates via Dependabot.

| Action | Current Version | Notes |
|--------|----------------|-------|
| `actions/checkout` | v6.0.1 (SHA-pinned) | Core checkout |
| `ruby/setup-ruby` | v1.268.0 (SHA-pinned) | Ruby setup |
| `astral-sh/setup-uv` | v7.1.6 (SHA-pinned) | Python for lint tools |
| `github/codeql-action/upload-sarif` | v4.31.6 (SHA-pinned) | Security SARIF upload |
| `re-actors/alls-green` | v1.2.2 (SHA-pinned) | Job status aggregation |

### Python Linting Tools

Managed via `pylock.toml` in `.github/workflows/lint/`:

| Tool | Purpose |
|------|---------|
| codespell | Spell checking |
| yamllint | YAML validation |
| zizmor | Workflow security scanning |

---

## 4. Cargo (Rust) Dependencies

RubyGems includes Rust extension tests:

| Path | Purpose |
|------|---------|
| `test/rubygems/test_gem_ext_cargo_builder/custom_name/ext/` | Cargo builder tests |
| `test/rubygems/test_gem_ext_cargo_builder/rust_ruby_example/` | Rust-Ruby example |

Dependencies managed by Dependabot (monthly updates).

---

## 5. Dependency Health Assessment

| Component | Status | Risk |
|-----------|--------|------|
| Core Ruby (stdlib) | ✅ No external deps | None |
| Vendored libs | ✅ Pinned versions | Low |
| GitHub Actions | ✅ SHA-pinned | Low |
| Python lint tools | ✅ Dependabot managed | Low |
| Cargo/Rust | ✅ Dependabot managed | Low |

---

## 6. Outdated Dependency Check

### Recommendations

1. **Monthly review**: Dependabot is configured for monthly action updates
2. **Vendored libs**: Review vendored libraries quarterly for security patches
3. **Cargo deps**: Monitor `rb-sys` crate for updates (tracked by Dependabot)

---

## 7. Upgrade Recommendations

| Package | Type | Priority | Notes |
|---------|------|---------|-------|
| GitHub Actions | CI | Auto (Dependabot) | Monthly automated |
| Python lint tools | Dev | Low | Updated via pylock.toml |
| Vendored gems | Core | Medium | Manual review needed |
| Rust crates | Test | Auto (Dependabot) | Monthly automated |

---

## 8. Adding New Dependencies

Before adding a new dependency:

1. Check the [Ruby Advisory Database](https://rubysec.com/) for known vulnerabilities
2. Evaluate if vendoring is needed for security isolation
3. Add to Dependabot configuration for automated updates
4. Document the rationale in `CONTRIBUTING.md`

---

## References

- [Ruby Advisory Database](https://rubysec.com/)
- [Dependabot config](.github/dependabot.yml)
- [OSSF Security Scorecard](https://securityscorecards.dev/)
