# frozen_string_literal: true

require "rubygems/package"
require "set"
require "yaml"

gem_path = Dir[File.expand_path("../pwindows-theme-*.gem", __dir__)].max
abort "Theme gem was not built" unless gem_path

files = Gem::Package.new(gem_path).spec.files

required = %w[_data/languages.yml _data/translations.yml _layouts/default.html _includes/schema-org.html assets/css/style.css assets/js/main.js lib/pwindows-theme.rb README.md LICENSE]
missing = required.reject { |path| files.include?(path) }
abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?

forbidden = files.grep(%r{\A(?:assets/extra/|tools/|\.github/)})
abort "Forbidden packaged files: #{forbidden.join(', ')}" unless forbidden.empty?

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

css = File.read(File.expand_path("../assets/css/style.css", __dir__))
required_css = ["--content-width:", "--topbar-height:", "overflow-y: auto", "[dir=\"rtl\"]", "@media (prefers-reduced-motion: reduce)"]
missing_css = required_css.reject { |value| css.include?(value) }
abort "Missing responsive/accessibility CSS: #{missing_css.join(', ')}" unless missing_css.empty?
abort "Invalid CSS value remains" if css.lines.any? { |line| line.match?(/(?:padding|margin|border)[^:]*:\s*none\b/) }
abort "Non-WOFF2 Alibaba font is referenced" if css.match?(/AlibabaPuHuiTi[^\n]+\.(?:ttf|woff)[\"')]/)

plugin = File.read(File.expand_path("../lib/pwindows-theme.rb", __dir__))
abort "Theme asset exclusion hook is missing" unless plugin.include?(":post_read") && plugin.include?('"assets", "extra"')

puts "Theme package verification passed (#{files.length} files)."
