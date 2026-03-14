# RubyGems Authentication

This document describes how RubyGems authenticates with gem servers such as
[RubyGems.org](https://rubygems.org) when pushing, yanking, or managing gem
owners.

## Signing In

Use the `gem signin` command to authenticate with a gem server:

```bash
gem signin
```

This prompts for your username/email and password, creates an API key on the
server, and stores it locally. By default it connects to RubyGems.org; use
`--host` to target a different server:

```bash
gem signin --host https://my.private.server
```

## Credentials File

After signing in, the API key is saved in the credentials file. You can check
its location with:

```bash
gem environment credentials
```

The default path is `~/.gem/credentials`. The file uses YAML format and stores
API keys per host:

```yaml
:rubygems_api_key: rubygems_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
https://my.private.server: rubygems_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

The credentials file should be kept private (mode `0600`).

## API Key Scopes

When signing in you can choose the access scopes granted to the new API key.
The default scopes are `index_rubygems` and `push_rubygem`. Available scopes
are:

| Scope | Description |
|---|---|
| `index_rubygems` | List gems in the index |
| `push_rubygem` | Push new gem versions |
| `yank_rubygem` | Yank existing gem versions |
| `add_owner` | Add owners to a gem |
| `remove_owner` | Remove owners from a gem |
| `access_webhooks` | Manage gem webhooks |
| `show_dashboard` | Access the user dashboard (exclusive scope) |

Exclusive scopes (like `show_dashboard`) cannot be combined with other scopes.

You can also name your API key during sign in. A default name is generated
from your hostname, username and a timestamp if you leave the prompt blank.

If a key is missing a required scope for an operation you will be prompted to
sign in again to add the scope.

## Environment Variables

You can supply authentication credentials through environment variables to
avoid interactive prompts, which is useful in CI/CD pipelines.

### `GEM_HOST_API_KEY`

Set this variable to an API key to authenticate without running `gem signin`:

```bash
export GEM_HOST_API_KEY=rubygems_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
gem push my-gem-1.0.gem
```

This takes precedence over any key stored in the credentials file.

### `GEM_HOST_OTP_CODE`

If your account has multi-factor authentication (MFA) enabled, provide the
one-time password (OTP) code via this variable:

```bash
export GEM_HOST_OTP_CODE=123456
gem push my-gem-1.0.gem
```

You can also pass the OTP code directly with the `--otp` flag:

```bash
gem push my-gem-1.0.gem --otp 123456
```

### `RUBYGEMS_HOST`

Set the default gem server host so you do not need to pass `--host` on every
command:

```bash
export RUBYGEMS_HOST=https://my.private.server
gem push my-gem-1.0.gem
```

## Multi-Factor Authentication (MFA)

RubyGems supports two MFA methods:

### OTP (one-time password)

If OTP-based MFA is enabled you will be prompted to enter a 6-digit code from
your authenticator app. You can provide it non-interactively with the
`--otp` option or the `GEM_HOST_OTP_CODE` environment variable.

### WebAuthn (security device)

If WebAuthn MFA is configured, the CLI will provide a URL to open in your
browser where you can authenticate with your security device (e.g. a hardware
key). After successful authentication the CLI receives a token automatically
and continues.

## Using Named API Keys

You can store multiple named API keys in the credentials file and select one
with the `--key` flag:

```bash
gem push my-gem-1.0.gem --key my-work-key
```

Named keys are stored in the credentials file under a symbolic name:

```yaml
:my-work-key: rubygems_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Signing Out

To remove all stored API keys from the credentials file:

```bash
gem signout
```

## See Also

- `gem help signin`
- `gem help signout`
- `gem help push`
- `gem help environment`
- [RubyGems.org API key management](https://rubygems.org/profile/api_keys)
