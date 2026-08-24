Gem::Specification.new do |spec|
  spec.name          = "pwindows-theme"
  spec.version       = "1.0.0"
  spec.authors       = ["PeterMaZep"]
  spec.email         = ["petermazep@pwindows.qzz.io"]

  spec.summary       = "Shared theme for PWindows websites"
  spec.homepage      = "https://github.com/PWindows/website-common"
  spec.license       = "Nonstandard"
  spec.required_ruby_version = ">= 3.1"

  spec.files         = `git ls-files -z --cached`.split("\x0").select do |f|
    File.file?(f) && f.match?(%r{^(_(data|includes|layouts|sass)/|assets/|lib/|README|LICENSE)}i) &&
      !f.start_with?("assets/extra/")
  end

  spec.add_runtime_dependency "jekyll", "~> 4.4"

  spec.add_development_dependency "bundler", "~> 2.0"
end
