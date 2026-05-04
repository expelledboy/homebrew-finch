cask "finch" do
  version "0.1.0"
  sha256 "4c972fc1774c8a1b278744475ac2f74f08db0b03511147e2265c5a32c28cda57"

  url "https://github.com/expelledboy/finch/archive/refs/tags/v#{version}.tar.gz"
  name "Finch"
  desc "Tiny, fast macOS browser router (Finicky alternative)"
  homepage "https://github.com/expelledboy/finch"

  depends_on macos: ">= :ventura"
  depends_on xcode: ["15.0", :build]

  # Build the .app from source. Locally-compiled binaries don't carry the
  # com.apple.quarantine xattr, so Gatekeeper allows the unsigned bundle to
  # run without prompting.
  preflight do
    system_command "/usr/bin/make",
                   args: ["build"],
                   chdir: staged_path,
                   must_succeed: true
  end

  app "Finch.app"

  postflight do
    # Force Launch Services to index the new bundle immediately so it shows
    # up in System Settings → Default web browser without a re-login.
    system_command "/System/Library/Frameworks/CoreServices.framework/Versions/A/" \
                   "Frameworks/LaunchServices.framework/Versions/A/Support/lsregister",
                   args: ["-f", "#{appdir}/Finch.app"],
                   must_succeed: false
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
