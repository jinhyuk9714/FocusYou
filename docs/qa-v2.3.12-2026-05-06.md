# FocusYou v2.3.12 Full QA Report - 2026-05-06

## Summary

- QA target: `v2.3.12` release DMG plus Debug automation build.
- Repo state at start: `main...origin/main`, `HEAD=b8ac1dd`, tag `v2.3.12`.
- Evidence directory: `/tmp/focusyou-v2312-fullqa.HvLobr`
- Final state: `PASS` for `assert-clean` and `assert-helper-ready`.
- User-blocking app failures found: none.

## Environment Notes

- macOS host has iCloud Private Relay enabled. FocusYou surfaced the expected warning that Safari hosts blocking can be bypassed while Chrome/Firefox remain covered.
- `sudo -n true` is not available in this shell, but the configured helper sudo rule is available:
  - `sudo -n -l /usr/local/bin/focusyou-helper`: `OK`
  - arbitrary `sudo mv` / reboot commands: blocked by password requirement.
- Release app launched from a temporary install location as a menu-bar process. Computer Use / AppleScript activation timed out against the release process, so release UI was verified by launch/process smoke while detailed window navigation was verified in the Debug app.

## Release DMG Verification

| Scenario | Status | Evidence |
| --- | --- | --- |
| GitHub Release metadata read for `v2.3.12` | PASS | Asset `FocusYou-2.3.12.dmg`, release URL `https://github.com/jinhyuk9714/FocusYou/releases/tag/v2.3.12` |
| Public asset downloaded fresh | PASS | `/tmp/focusyou-v2312-fullqa.HvLobr/release/FocusYou-2.3.12.dmg` |
| SHA256 matches Release asset digest | PASS | `b62850792c366712dae6030c14c5cfe0ef1983e60ef148d562fa29cb29ecc4e3` |
| DMG Gatekeeper open assessment | PASS | `accepted`, source `Notarized Developer ID` |
| DMG mount | PASS | Mounted at `/Volumes/Focus You` |
| App codesign verify | PASS | `valid on disk`, satisfies designated requirement |
| App Gatekeeper execute assessment | PASS | `accepted`, source `Notarized Developer ID` |
| Signing identity | PASS | Developer ID Application: JINHYUK SUNG (`9VRNY5PMG3`) |
| Temporary install and first process launch | PASS | Release app launched from `/tmp/.../release-install/Focus You.app` |
| Release UI window inspection | BLOCKED | Menu-bar release process launched, but Computer Use / AppleScript activation timed out. Debug UI covered equivalent settings and dashboard navigation. |

## Debug Automation

| Scenario | Status | Evidence |
| --- | --- | --- |
| Debug build | PASS | `xcodebuild ... build`, `BUILD SUCCEEDED` |
| QA script syntax | PASS | `bash -n scripts/qa_focusyou_state.sh` |
| QA script fixture tests | PASS | `bash scripts/test_qa_focusyou_state.sh` |
| `qa-smoke-start-stop` | PASS | Start created hosts markers; stop returned `assert-clean` |
| `qa-smoke-data-tools` | PASS | Backup and diagnostics bundles created and validated |
| `qa-smoke-recovery-import` | PASS | Synthetic backup preview plus default/history dry-run import passed |
| AppIntents unit smoke | PASS | `FocusYouTests/AppIntentsTests`: 14 tests, 0 failures |
| Full test suite | PASS | `xcodebuild ... test`: 313 XCTest tests + 170 Swift Testing tests, 0 failures |
| Static analyze | PASS | `xcodebuild ... analyze`: `ANALYZE SUCCEEDED` |

## Manual UI Matrix

| Area | Scenario | Status | Notes |
| --- | --- | --- | --- |
| Dashboard | Launch / idle dashboard | PASS | Dashboard opened in Debug app. |
| Dashboard | Private Relay warning | PASS | Warning and Settings button shown as expected. |
| Timer | Free session start | PASS | UI start changed state to focusing. |
| Timer | Pause / resume | PASS | Buttons changed between `일시정지` and `재개`; state updated. |
| Timer | Stop confirmation | PASS | Stop asked for confirmation; confirmed stop returned idle. |
| Timer | Natural completion | PASS | Verified with Debug Fast Timer plus active hosts blocking. |
| Timer | Pomodoro / Flowmodoro transitions | PASS | Covered by `AppStateCharacterizationTests`, `PomodoroEngineTests`, `FlowmodoroEngineTests`, and full test pass. |
| Blocking | Empty block list | PASS | UI showed 0 sites / 0 apps and timer-only start remained usable. |
| Blocking | Invalid domain | PASS | `https://bad domain` produced `올바른 URL을 입력해주세요` and did not add a site. |
| Blocking | Site blocklist / allowlist / keyword pattern | PASS | Covered by `AdvancedBlockingTests` and session smoke with hosts markers. |
| Blocking | App blocking list | PASS | Installed apps listed with toggles and free limit display. No toggle was persisted during QA. |
| Blocking | Category presets | PASS | SNS, news, video, game presets visible. No preset was persisted during QA. |
| Profiles | Default profile selection | PASS | Default profile visible on dashboard and block list. |
| Profiles | New profile / conflict names | PASS | Covered by profile/import tests; not persisted manually during this run. |
| Schedules | Start/rejoin/end boundaries | PASS | Covered by `ScheduleManager` and AppState lifecycle tests. |
| Settings | General tab | PASS | Subscription, language, appearance, menu-bar/sound/app notification/login switches, version `2.3.12 (34)` visible. |
| Settings | Focus tab | PASS | Pro-gated intention, quotes, reflection, burnout settings visible and off for free state. |
| Settings | Integrations tab | PASS | Pro-gated Focus Mode, Calendar, schedule settings visible and off. |
| Settings | Advanced diagnostics | PASS | Private Relay, hosts state, data store state, DNS cache, Debug Fast Timer, onboarding reset visible. |
| Data tools | Data tool menu | PASS | Backup, preview, import, diagnostics export actions visible. |
| Data tools | Backup / diagnostics generation | PASS | Verified through Debug automation using the same services. |
| Data tools | Backup preview / import dry-run | PASS | Verified through fixture-based Debug QA automation. |
| Data tools | Session/badge toggles default OFF | PASS | Covered by `QAAutomationDataToolTests` and import presentation tests. |
| Data tools | Duplicate/new session and badge counts | PASS | Covered by v2.3.12 duplicate-preview tests in full suite. |
| Safe mode | Import button hidden | PASS | Covered by current UI policy and tests; safe-mode import was not manually induced in this run. |
| AppIntents / Shortcuts | Store failure fallback dialog | PASS | Covered by AppIntents tests. |
| AppIntents / Shortcuts | macOS Shortcuts CLI listing | NOT APPLICABLE | `shortcuts list` showed existing FocusYou DND shortcuts only; AppIntents are covered by tests instead. |
| StoreKit / Pro purchase | Real purchase | NOT APPLICABLE | No real purchase performed. Free/pro gating visible in UI and covered by subscription tests. |

## Recovery And Failure Matrix

| Scenario | Status | Evidence / Result |
| --- | --- | --- |
| Pre-QA clean baseline | PASS | `assert-clean`, `assert-helper-ready` passed. |
| Active blocking, normal stop | PASS | `qa-smoke-start-stop` created markers and removed them on stop. |
| Active blocking, timer completion | PASS | With Debug Fast Timer, a 60-second blocked session completed and returned `assert-clean`. |
| Active blocking, `kill -9`, relaunch recovery | PASS | Safety net armed, app killed, markers remained until relaunch, relaunch cleaned them and `assert-recovered` passed. |
| Active blocking, reboot recovery | BLOCKED | Reboot requires user/password and would terminate this Codex session. `sudo -n true` failed with password requirement. |
| Helper disabled cleanup failure | BLOCKED | `sudo mv /usr/local/bin/focusyou-helper ...` cannot be run non-interactively in this environment. |
| Final clean state | PASS | `assert-clean` and `assert-helper-ready` passed after all executed tests. |

## Observations / Follow-Up Candidates

1. `qa_focusyou_state.sh snapshot` has a noisy process detector. It uses `pgrep -ifl "Focus You|FocusYou"` and can report the current `tee` command as an app process when the log path contains `focusyou`. This did not affect pass/fail checks, but it makes snapshots less clean.
2. `qa-start-session 3 ...` is clamped to the product minimum of 60 seconds. Timer-completion QA is still possible with Debug Fast Timer, but a dedicated QA-only short-completion action would make this scenario less surprising.
3. Full reboot recovery and helper-disabled failure need a user-attended machine session or a controlled CI/macOS VM with passwordless disruptive operations.

## Final Commands

```bash
./scripts/release_preflight.sh --stage tagged --expected-tag v2.3.12
bash -n scripts/qa_focusyou_state.sh
bash scripts/test_qa_focusyou_state.sh
xcodegen generate
xcodebuild -project FocusYou.xcodeproj -scheme FocusYou -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
xcodebuild -project FocusYou.xcodeproj -scheme FocusYou -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO analyze
git diff --check
./scripts/qa_focusyou_state.sh assert-clean
./scripts/qa_focusyou_state.sh assert-helper-ready
```

Final result:

- `release_preflight --stage tagged`: PASS
- QA script tests: PASS
- Full unit tests: PASS, 313 XCTest tests + 170 Swift Testing tests
- Analyze: PASS
- Final `assert-clean`: PASS
- Final `assert-helper-ready`: PASS
