#!/bin/bash
# Paste into the cloud environment's Setup script (claude.ai/code → environment menu → Edit).
# One environment serves every Flutter repo: it installs the SDK; each session runs
# `flutter pub get` itself (cloud-test.md), since packages differ per repo.
# ponytail: no set -e — a failed step still lets the session start, so cloud-test.md
# reports "Environment broken" instead of a session that never opens.
FLUTTER_VERSION=3.47.9 # keep in step with `flutter --version` on the team's Macs
[ -x /opt/flutter/bin/flutter ] ||
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /opt/flutter
git config --system --add safe.directory /opt/flutter
ln -sf /opt/flutter/bin/flutter /usr/local/bin/flutter
ln -sf /opt/flutter/bin/dart /usr/local/bin/dart
flutter config --no-analytics >/dev/null
flutter --version
