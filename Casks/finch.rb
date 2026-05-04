cask "finch" do
  version "0.1.1"
  sha256 "d5d99e79af4e0fe61f19a83db124904f9f29a1a5c8cd34936b32540950621b2a"

  url "https://github.com/expelledboy/finch/archive/refs/tags/v#{version}.tar.gz"
  name "Finch"
  desc "Tiny, fast browser router and Finicky alternative"
  homepage "https://github.com/expelledboy/finch"

  depends_on macos: ">= :ventura"

  # Build the .app from source. Locally-compiled binaries don't carry the
  # com.apple.quarantine xattr, so Gatekeeper allows the unsigned bundle to
  # run without prompting. Requires the Xcode Command Line Tools — if `swift`
  # is missing, this preflight fails with a clear error.
  preflight do
    src = "#{staged_path}/finch-#{version}"
    unless system "/usr/bin/xcrun", "--find", "swift", out: File::NULL, err: File::NULL
      odie "Finch builds from source and needs the Xcode Command Line Tools.\n" \
           "Install them with: xcode-select --install"
    end
    system_command "/usr/bin/make",
                   args:         ["build"],
                   chdir:        src,
                   must_succeed: true
  end

  app "finch-#{version}/Finch.app", target: "Finch.app"

  postflight do
    # Force Launch Services to index the new bundle immediately so it shows
    # up in System Settings → Default web browser without a re-login.
    system_command "/System/Library/Frameworks/CoreServices.framework/Versions/A/" \
                   "Frameworks/LaunchServices.framework/Versions/A/Support/lsregister",
                   args:         ["-f", "#{appdir}/Finch.app"],
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
