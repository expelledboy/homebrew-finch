cask "finch" do
  version "0.2.1"
  sha256 "a814e82b380deeac295ec765083e264a296b81fb0c665c3d605351b6b5c0b9ae"

  url "https://github.com/expelledboy/finch/archive/refs/tags/v#{version}.tar.gz"
  name "Finch"
  desc "Tiny, fast browser router and Finicky alternative"
  homepage "https://github.com/expelledboy/finch"

  depends_on macos: :ventura

  # No lsregister step: Launch Services indexes an app as it lands in
  # /Applications, and Homebrew's sandbox would block one anyway
  app "finch-#{version}/Finch.app", target: "Finch.app"

  # Build the .app from source. Locally-compiled binaries don't carry the
  # com.apple.quarantine xattr, so Gatekeeper allows the unsigned bundle to
  # run without prompting. Requires Xcode or its Command Line Tools
  # (`xcode-select --install`); without them `make` fails with xcrun's
  # "invalid active developer path". Install steps run in Homebrew's sandbox:
  # the Makefile turns off SwiftPM's own, which cannot nest inside it.
  preflight_steps do
    run "/usr/bin/make", args: ["build"], chdir: "finch-#{version}"
  end

  uninstall quit: "com.finch.browser"

  zap trash: [
    "~/.finch.js",
    "~/Library/Preferences/com.finch.browser.plist",
    "~/Library/Saved Application State/com.finch.browser.savedState",
  ]

  caveats <<~EOS
    Finch installed at #{appdir}/Finch.app

    To start using it:
      1. Launch Finch (a 🐦 icon will appear in your menu bar)
      2. Create your config at ~/.finch.js
         See: https://github.com/expelledboy/finch/blob/main/examples/finch.example.js
      3. System Settings → Desktop & Dock → Default web browser → Finch

    Reload config after editing:
      kill -HUP $(pgrep -f Finch.app/Contents/MacOS/Finch)
  EOS
end
