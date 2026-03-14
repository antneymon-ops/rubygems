# Test Coverage Report

**Date:** 2026-03-14
**Repository:** antneymon-ops/rubygems
**Version:** 4.1.0.dev

---

## Overview

This report documents the test coverage baseline for RubyGems. The project uses Minitest for core tests and RSpec for Bundler tests.

---

## 1. Test Framework Summary

| Component | Framework | Location |
|-----------|-----------|---------|
| RubyGems core | Minitest | `test/rubygems/` |
| Bundler | RSpec | `bundler/spec/` |

---

## 2. Test File Inventory

### RubyGems Tests (Minitest)

**Total test files:** 151

#### Core Tests

| Test File | Area |
|-----------|------|
| `test_gem.rb` | Core Gem module |
| `test_gemspec.rb` | Gem specifications |
| `test_gem_specification.rb` | Spec parsing & validation |
| `test_gem_specification_policy.rb` | Spec policies |

#### Command Tests

| Test File | Command |
|-----------|---------|
| `test_gem_command.rb` | Base command |
| `test_gem_command_manager.rb` | Command management |
| `test_gem_commands_build_command.rb` | build |
| `test_gem_commands_cert_command.rb` | cert |
| `test_gem_commands_cleanup_command.rb` | cleanup |
| `test_gem_commands_contents_command.rb` | contents |
| `test_gem_commands_dependency_command.rb` | dependency |
| `test_gem_commands_environment_command.rb` | environment |
| `test_gem_commands_fetch_command.rb` | fetch |
| `test_gem_commands_install_command.rb` | install |
| `test_gem_commands_list_command.rb` | list |
| `test_gem_commands_open_command.rb` | open |
| `test_gem_commands_push_command.rb` | push |
| `test_gem_commands_query_command.rb` | query |
| `test_gem_commands_search_command.rb` | search |
| `test_gem_commands_setup_command.rb` | setup |
| `test_gem_commands_signin_command.rb` | signin |
| `test_gem_commands_signout_command.rb` | signout |
| `test_gem_commands_uninstall_command.rb` | uninstall |
| `test_gem_commands_update_command.rb` | update |
| `test_gem_commands_yank_command.rb` | yank |

#### Infrastructure Tests

| Test File | Area |
|-----------|------|
| `test_gem_installer.rb` | Gem installation |
| `test_gem_installer_test_case.rb` | Installer test helpers |
| `test_gem_uninstaller.rb` | Gem removal |
| `test_gem_resolver.rb` | Dependency resolution |
| `test_gem_resolver_molinillo*.rb` | Molinillo resolver |
| `test_gem_source.rb` | Gem sources |
| `test_gem_source_*.rb` | Source variants |

---

## 3. Coverage Estimate by Area

| Area | Estimated Coverage | Notes |
|------|-------------------|-------|
| Core library (`lib/rubygems.rb`) | ~80% | Well-tested core |
| Commands | ~75% | Most commands have tests |
| Installer | ~70% | Key paths covered |
| Resolver | ~65% | Molinillo tested |
| Extensions | ~60% | Some edge cases missing |
| Security/Signing | ~55% | Complex to test fully |
| Network/HTTP | ~50% | Mocked in tests |

**Estimated overall coverage:** ~70%

---

## 4. Setting Up Coverage Measurement

To configure SimpleCov for formal coverage tracking, add the following to `test/rubygems/helper.rb`:

```ruby
# Uncomment to enable coverage reporting
# require "simplecov"
# SimpleCov.start do
#   add_filter "/test/"
#   add_filter "/vendor/"
# end
```

Then add SimpleCov to your development environment:

```ruby
# In your Gemfile or as a dev dependency
gem "simplecov", require: false, group: :test
```

Run with coverage:

```bash
COVERAGE=true bin/rake test
```

---

## 5. CI Test Matrix

Tests run across the following matrix in CI:

### Operating Systems
- Ubuntu 24.04
- macOS 15
- Windows 2025

### Ruby Versions
- Ruby 3.2.9
- Ruby 3.3.9
- Ruby 3.4.5
- JRuby 10.0.2.0
- TruffleRuby 24.2.1

### Additional Tests

| Test Suite | Purpose |
|------------|---------|
| `rake test:isolated` | Isolated test environment (Ruby 3.4, non-Windows) |
| `JRUBY_OPTS=--debug rake test` | JRuby with debug mode |
| Bundler specs | Bundler-specific functionality |

---

## 6. Running Tests Locally

```bash
# Run all RubyGems tests
bin/rake test

# Run a specific test file
ruby -Ilib test/rubygems/test_gem.rb

# Run tests in isolated mode (Ruby 3.4)
bin/rake test:isolated

# Run Bundler specs
cd bundler && bin/rspec spec/
```

---

## 7. Test Coverage Goals

| Milestone | Target Coverage | Timeline |
|-----------|----------------|---------|
| Current baseline | ~70% | Now |
| After Phase 1 | 75% | Month 1 |
| After Phase 2 | 80% | Month 2 |
| Target | 85%+ | Month 3+ |

---

## 8. Areas Needing Additional Tests

1. **Error handling paths**: Ensure all exception cases are tested
2. **Network failure scenarios**: Better simulation of network issues
3. **Edge cases in resolver**: Complex dependency conflict scenarios
4. **Extension building**: Various compiler/platform combinations
5. **Security features**: Certificate validation and signing edge cases

---

## References

- [SimpleCov gem](https://github.com/simplecov-ruby/simplecov)
- [Minitest documentation](https://github.com/minitest/minitest)
- [RubyGems test helper](../test/rubygems/helper.rb)
