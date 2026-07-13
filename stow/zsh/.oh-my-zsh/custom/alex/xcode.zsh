# -----------------------------------------------------------------------------
# Xcode beta — opt-in, one command at a time
#
# The stable Xcode stays the default for everything: xcode-select must keep
# pointing at /Applications/Xcode.app, so xcodebuild, SPM, fastlane, agents and
# every script keep building against the *released* SDK. An App Store build cannot
# be compiled against a beta SDK, so a beta toolchain must never become global.
#
# Never run: sudo xcode-select -s /Applications/Xcode-beta.app/...
# Run instead: xcb xcodebuild -version
#              xcb xcodebuild -project Foo.xcodeproj -scheme Foo build
# -----------------------------------------------------------------------------
xcb() {
    local dev="/Applications/Xcode-beta.app/Contents/Developer"

    if [[ ! -d "$dev" ]]; then
        print -u2 "xcb: no Xcode-beta.app in /Applications (check the bundle name)."
        return 1
    fi

    if (( $# == 0 )); then
        print -u2 "usage: xcb <command> [args...]   e.g. xcb xcodebuild -version"
        return 64
    fi

    DEVELOPER_DIR="$dev" "$@"
}

# Which toolchain is globally active, and where the beta sits.
xcodes() {
    print "active (xcode-select): $(xcode-select -p)"
    print "version:               $(xcodebuild -version | head -1)"
    print -n "beta:                  "
    if [[ -d /Applications/Xcode-beta.app ]]; then
        print "$(xcb xcodebuild -version | head -1) (opt-in via xcb)"
    else
        print "not installed"
    fi
}
