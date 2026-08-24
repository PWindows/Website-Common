# frozen_string_literal: true

require "rubygems/package"
require "set"
require "yaml"

gem_path = Dir[File.expand_path("../pwindows-theme-*.gem", __dir__)].max
abort "Theme gem was not built" unless gem_path

files = Gem::Package.new(gem_path).spec.files

required = %w[_data/languages.yml _data/translations.yml _data/ui.yml _layouts/default.html _includes/i18n-head.html _includes/schema-org.html assets/css/style.css assets/js/main.js lib/pwindows-theme.rb README.md LICENSE]
missing = required.reject { |path| files.include?(path) }
abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?

forbidden = files.grep(%r{\A(?:assets/extra/|tools/|\.github/)})
abort "Forbidden packaged files: #{forbidden.join(', ')}" unless forbidden.empty?

tracked_files = `git ls-files -z`.split("\0")
untracked_package_files = files.reject { |path| tracked_files.include?(path) }
abort "Gem contains files not tracked by Git: #{untracked_package_files.join(', ')}" unless untracked_package_files.empty?

consumer_assets = files.grep(%r{\Aassets/(?:img/(?:obby-of-dominance|sacred-remains)|staffpfp/)})
abort "Website-only assets remain in the theme: #{consumer_assets.join(', ')}" unless consumer_assets.empty?

text_extensions = %w[.css .html .js .json .md .rb .txt .xml .yml]
source_files = Dir.glob(File.expand_path("../{_data,_includes,_layouts,assets}/**/*", __dir__)).select do |path|
  File.file?(path) && text_extensions.include?(File.extname(path))
end
conflicts = source_files.select { |path| File.read(path).match?(/^(?:<<<<<<<|=======|>>>>>>>)/) }
abort "Conflict markers remain in: #{conflicts.join(', ')}" unless conflicts.empty?

languages = YAML.safe_load_file(File.expand_path("../_data/languages.yml", __dir__), aliases: true)
translations = YAML.safe_load_file(File.expand_path("../_data/translations.yml", __dir__), aliases: true)
ui = YAML.safe_load_file(File.expand_path("../_data/ui.yml", __dir__), aliases: true)
abort "Translation languages do not match language catalog" unless translations.keys.to_set == languages.keys.to_set
abort "UI languages do not match language catalog" unless ui.keys.to_set == languages.keys.to_set
abort "Arabic and Hebrew must be RTL" unless %w[ar-sa he-il].all? { |language| languages.dig(language, "direction") == "rtl" }
required_ui = %w[skip_to_content discord_label youtube_label twitter_label]
missing_ui = ui.filter_map do |language, values|
  missing_keys = required_ui.reject { |key| values[key].to_s.strip.length.positive? }
  "#{language}: #{missing_keys.join(', ')}" if missing_keys.any?
end
abort "Missing localized accessibility labels: #{missing_ui.join('; ')}" unless missing_ui.empty?

css = File.read(File.expand_path("../assets/css/style.css", __dir__))
required_css = ["--content-width:", "--topbar-height:", "overflow-y: auto", "[dir=\"rtl\"]", "@media (prefers-reduced-motion: reduce)"]
missing_css = required_css.reject { |value| css.include?(value) }
abort "Missing responsive/accessibility CSS: #{missing_css.join(', ')}" unless missing_css.empty?
abort "Invalid CSS value remains" if css.lines.any? { |line| line.match?(/(?:padding|margin|border)[^:]*:\s*none\b/) }
abort "Non-WOFF2 Alibaba font is referenced" if css.match?(/AlibabaPuHuiTi[^\n]+\.(?:ttf|woff)[\"')]/)

abort "Blanket responsive button selector remains" if css.include?(".btn:not(.nav-item)")
physical_css = css.lines.grep(/(?:padding-right|margin-right|text-align:\s*left|\bleft:|\bright:)/)
abort "Physical-direction CSS remains: #{physical_css.join.strip}" unless physical_css.empty?

layout = File.read(File.expand_path("../_layouts/default.html", __dir__))
abort "Localized skip link is missing" unless layout.include?('class="skip-link"') && layout.include?("ui.skip_to_content")
abort "Polyglot I18n_Headers must not generate metadata" if layout.include?("I18n_Headers")
abort "Consumer site_meta interface is missing" unless layout.include?("site.data.site_meta")

i18n_head = File.read(File.expand_path("../_includes/i18n-head.html", __dir__))
%w[canonical alternate hreflang x-default site.languages].each do |hook|
  abort "International metadata hook is missing #{hook}" unless i18n_head.include?(hook)
end

javascript = File.read(File.expand_path("../assets/js/main.js", __dir__))
abort "Mobile menu background inert handling is missing" unless javascript.include?("setBackgroundInert") && javascript.include?("dataset.menuInert")

schema = File.read(File.expand_path("../_includes/schema-org.html", __dir__))
abort "Consumer schema extension point is missing" unless schema.include?("content_for_schema")

plugin = File.read(File.expand_path("../lib/pwindows-theme.rb", __dir__))
abort "Theme asset exclusion hook is missing" unless plugin.include?(":post_read") && plugin.include?('"assets", "extra"')

puts "Theme package verification passed (#{files.length} files)."
