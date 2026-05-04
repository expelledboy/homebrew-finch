# homebrew-finch

Homebrew tap for [Finch](https://github.com/expelledboy/finch), a tiny macOS browser router.

## Install

```sh
brew tap expelledboy/finch
brew install --cask finch
```

Or in one line:

```sh
brew install --cask expelledboy/finch/finch
```

The cask builds Finch from source on your machine using `swift build`. This
requires Xcode or the Command Line Tools (`xcode-select --install`). It also
sidesteps the unsigned-binary Gatekeeper warning that an unnotarized download
would trigger.

After install:
1. Launch Finch — a 🐦 icon appears in your menu bar
2. Create `~/.finch.js` ([example](https://github.com/expelledboy/finch/blob/main/examples/finch.example.js))
3. System Settings → Desktop & Dock → Default web browser → Finch

## Update

```sh
brew update && brew upgrade --cask finch
```

## Uninstall

```sh
brew uninstall --cask finch          # leaves config at ~/.finch.js
brew uninstall --cask --zap finch    # also removes config and prefs
```
