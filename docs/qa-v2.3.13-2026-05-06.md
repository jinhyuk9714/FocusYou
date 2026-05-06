# FocusYou v2.3.13 Full QA Report - 2026-05-06

## Summary

- QA target: `v2.3.13` release DMG plus Debug automation build.
- Release commit: `76fe02c`
- Release tag: `v2.3.13`
- GitHub Release: `https://github.com/jinhyuk9714/FocusYou/releases/tag/v2.3.13`
- CI run: `https://github.com/jinhyuk9714/FocusYou/actions/runs/25389933915`
- Debug evidence directory: `/tmp/focusyou-v2313-debug-qa`
- Public asset smoke directory: `/tmp/focusyou-v2313-release-smoke.YLhoj4`
- Final state: `PASS` for `assert-clean` and `assert-helper-ready`.
- User-blocking app failures found: none.

## Environment Notes

- User-assisted QA was required for reboot and helper failure scenarios.
- `sudo -n true` is not available in this shell, but FocusYou helper sudo permission is configured:
  - `sudo -n -l /usr/local/bin/focusyou-helper`: `OK`
- Helper disable/restore used macOS administrator prompts through `osascript`.

## Release DMG Verification

| Scenario | Status | Evidence |
| --- | --- | --- |
| GitHub Release created | PASS | `v2.3.13`, URL above |
| Public asset downloaded fresh | PASS | `FocusYou-2.3.13.dmg` |
| SHA256 matches GitHub asset digest | PASS | `fa3a50c67f65a73047201f15b33d0b0d8a39689a9e4b71b125c7ba809f2dd876` |
| DMG Gatekeeper open assessment | PASS | `accepted`, source `Notarized Developer ID` |
| DMG mount | PASS | Mounted at `/Volumes/Focus You` |
| App codesign verify | PASS | `valid on disk`, satisfies designated requirement |
| App Gatekeeper execute assessment | PASS | `accepted`, source `Notarized Developer ID` |
| Temporary install and first launch | PASS | Release app launched from `/tmp/focusyou-v2313-release-smoke.YLhoj4/install/Focus You.app` |
| Release UI manual check | PASS | User confirmed menu bar, dashboard/settings/diagnostics, and quit flow did not block. |

## Automated Verification

| Scenario | Status | Evidence |
| --- | --- | --- |
| QA script syntax | PASS | `bash -n scripts/qa_focusyou_state.sh` |
| QA script fixture tests | PASS | `bash scripts/test_qa_focusyou_state.sh` |
| XcodeGen | PASS | `xcodegen generate` |
| Clean build | PASS | `xcodebuild ... clean build`: `BUILD SUCCEEDED` |
| Full test suite | PASS | `xcodebuild ... test`: 313 XCTest tests + 171 Swift Testing tests, 0 failures |
| Static analyze | PASS | `xcodebuild ... analyze`: `ANALYZE SUCCEEDED` |
| Risk-pattern scan | PASS | `rg -n "TODO|FIXME|fatalError\\(|try!|as!" FocusYou FocusYouTests` returned no matches |
| Diff whitespace check | PASS | `git diff --check` |
| Pre-tag release preflight | PASS | `./scripts/release_preflight.sh --stage pre-tag --expected-tag v2.3.13` |
| Tagged release preflight | PASS | `./scripts/release_preflight.sh --stage tagged --expected-tag v2.3.13` |
| GitHub Actions | PASS | `macOS Tests` run `25389933915`, job `test` success |

## Debug Automation

| Scenario | Status | Evidence |
| --- | --- | --- |
| Debug app process detection | PASS | Snapshot only reported the actual `Focus You.app/Contents/MacOS/Focus You` process |
| `qa-smoke-start-stop` | PASS | Start created hosts markers; stop returned `assert-clean` |
| `qa-smoke-completion-cleanup` | PASS | Completed active blocking session, cleanup returned `assert-clean` |
| `qa-smoke-data-tools` | PASS | Backup and diagnostics bundles created and validated |
| `qa-smoke-recovery-import` | PASS | Synthetic backup preview plus default/history dry-run import passed |

## Manual And Disruptive QA

| Scenario | Status | Evidence / Result |
| --- | --- | --- |
| Pre-QA clean baseline | PASS | `assert-clean`, `assert-helper-ready` |
| Active blocking, normal stop | PASS | Covered by `qa-smoke-start-stop` |
| Active blocking, timer completion | PASS | Covered by new `qa-smoke-completion-cleanup` |
| Active blocking, `kill -9`, relaunch recovery | PASS | `assert-recovery-pending` after kill, relaunch returned `assert-recovered` and `assert-clean` |
| Active blocking, reboot recovery | PASS | User rebooted with safety net armed; after login `assert-recovered` and `assert-helper-ready` passed |
| Helper disabled cleanup failure | PASS | Helper renamed, app relaunch left hosts markers and retry signals intact; `assert-recovery-pending` passed |
| Helper restore and recovery retry | PASS | Helper restored, app relaunch cleanup returned `assert-recovered`, `assert-clean`, and `assert-helper-ready` |
| Release UI manual check | PASS | User confirmed release app UI flow after signed DMG install smoke |
| Final clean state | PASS | `assert-clean`, `assert-helper-ready`, snapshot showed no app process and no recovery artifacts |

## Notes

- The v2.3.12 follow-up items were closed:
  - Snapshot no longer reports shell/log-path noise as the Focus You app process.
  - Timer completion cleanup can be checked with `qa-smoke-completion-cleanup`.
  - Reboot recovery and helper failure recovery were both user-assisted and passed.
- A first public asset smoke attempt stopped before app verification because this local `gh` version does not support the `isLatest` JSON field. The smoke was rerun with supported fields and passed.
- No app behavior, SwiftData schema, AppIntents, or recovery import policy changes were made for the release.

## Final Commands

```bash
bash -n scripts/qa_focusyou_state.sh
bash scripts/test_qa_focusyou_state.sh
xcodegen generate
xcodebuild -project FocusYou.xcodeproj -scheme FocusYou -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO clean build
xcodebuild -project FocusYou.xcodeproj -scheme FocusYou -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
xcodebuild -project FocusYou.xcodeproj -scheme FocusYou -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO analyze
./scripts/qa_focusyou_state.sh qa-smoke-start-stop 120 qa-v2313-startstop.example
./scripts/qa_focusyou_state.sh qa-smoke-completion-cleanup qa-v2313-complete.example
./scripts/qa_focusyou_state.sh qa-smoke-data-tools /tmp/focusyou-v2313-debug-qa/data-tools
./scripts/qa_focusyou_state.sh qa-smoke-recovery-import /tmp/focusyou-v2313-debug-qa/recovery-import
./scripts/release_preflight.sh --stage pre-tag --expected-tag v2.3.13
./scripts/release.sh
./scripts/release_preflight.sh --stage tagged --expected-tag v2.3.13
./scripts/qa_focusyou_state.sh assert-clean
./scripts/qa_focusyou_state.sh assert-helper-ready
```

Final result:

- Release DMG: PASS, signed and notarized
- GitHub Release: PASS
- Public asset smoke: PASS
- Debug automation: PASS
- Reboot recovery: PASS
- Helper failure recovery: PASS
- Final system state: PASS
