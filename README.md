# PWindows website theme

Shared Jekyll layouts, includes, translations, styles, scripts, and production assets used by the PWindows Website and Shop.

## Consumer setup

Add `pwindows-theme` from `https://github.com/PWindows/website-common.git`, set `theme: pwindows-theme`, and enable `jekyll-polyglot`. Consumer repositories own their content, site-specific data, favicons, and `assets/css/extra.css` / `assets/js/extra.js` overrides.

Retained source assets remain under `assets/extra/`. They are excluded from the gem manifest, and the theme's `post_read` hook removes theme-owned retained assets from Git-theme builds. Only production-ready assets are written to generated sites.

The complete Alibaba PuHuiTi CJK WOFF2 files are intentionally retained as a compatibility and localization exception. Their payload is accepted until a multilingual, reproducible subsetting pipeline is available.

Consumers may provide `_data/site_meta.yml`, keyed by locale, with `name`, `tagline`, `page_titles`, and `descriptions`. Missing active-locale values fall back to the default locale before the shared translation catalog.
