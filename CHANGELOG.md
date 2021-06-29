## 0.9.0

- Do not upload invalid type keys

## 0.8.1

- Fix bug in `CopyrayMiddleware`

## 0.8.0

- Change the default value of config.upload_disabled_environments

## 0.7.0

- Add config.upload_disabled_environments

## 0.6.2

- Add arguments to export task

## 0.6.1

- Fix ruby@2.7 keyword warning

## 0.6.0

- Drop support for ruby 2.4
- Drop support for rails 5.1

## 0.5.2

- Do not upload invalid keys

## 0.5.1

- Do not upload downloaded keys

## 0.5.0

- Drop support for ruby 2.3
- Add tt helper
- Add copy_tuner:detect_conflict_keys task
- Do not re-upload empty keys
- Fix dual loading tasks
- Remove config.copyray_js_injection_regexp_for_debug
- Remove config.copyray_js_injection_regexp_for_precompiled
- Download translation when initialization

## 0.4.11

- changes
  - Fix hide toggle button on mobile device.

## 0.4.10

- changes
  - Hide copyray bar on all media.

## 0.4.9

- changes
  - Smaller toggle button.
  - Hide toggle button on mobile device.

## 0.4.8

- changes
  - Support passenger 5.3.x

## 0.4.7

- changes
  - Compatibile with bullet gem (rewrap response with ActionDispatch::Response::RackBody)

## 0.4.6

- changes
  - Performance imporovement (sync with server asynchronously)
  - Add config.middleware_position

## 0.4.5

- changes
  - Fix deprecated css.

## 0.4.4

- bug fix
  - Don't upload resolved default values.

## 0.4.3

- bug fix
  - Start poller thread regardless of puma mode. #39

## 0.4.2

- changes
  - span tag is no longer added to translation text.

## 0.4.1

- bug fixes

  - js injection failed if jquery is not used. #33
  - Fix some js error. #34
  - Wrong key is displayed if scoped option is used. #35

- deprecation
  - config.copyray_js_injection_regexp_for_debug is no longer needed.
  - config.copyray_js_injection_regexp_for_precompiled is no longer needed.

## 0.4.0

- Remove jQuery dependency.

## 0.3.5

- Support Rails 5.1

## 0.3.4

- Use Logger to /dev/null as default when rails console

## 0.3.3

- Add config.locales. (#24)
- Fix initialization order bug. (#25)

## 0.3.2

- Support I18n.t :scope option.
- Update copyray_js_injection_regexp_for_debug.

## 0.3.1

- Add search box to copyray bar.
- Add disable_copyray_comment_injection to configuration.

## 0.3.0

- Use https as default.
- Download blurbs from S3.
- Add toolbar.
- "Translations in this page" menu.
