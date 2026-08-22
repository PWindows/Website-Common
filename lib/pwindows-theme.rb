# frozen_string_literal: true

require "jekyll"

Jekyll::Hooks.register :site, :post_read do |site|
  next unless site.theme

  retained_root = File.join(site.theme.root, "assets", "extra")
  retained_prefix = "#{retained_root}#{File::SEPARATOR}"

  site.static_files.reject! do |asset|
    path = File.expand_path(asset.path)
    path == retained_root || path.start_with?(retained_prefix)
  end

  site.pages.reject! do |page|
    base = page.instance_variable_get(:@base)
    next false unless base

    path = File.expand_path(page.path, base)
    path == retained_root || path.start_with?(retained_prefix)
  end
end
