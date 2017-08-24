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
  - config.copyray_js_injection_regexp_for_precompiled  is no longer needed.

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
