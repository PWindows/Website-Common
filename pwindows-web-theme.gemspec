em::Specification.new do |spec|
  spec.name          = "pwindows-theme"
  spec.version       = "1.0.0"
  spec.authors       = ["PeterMaZep"]
  spec.email         = ["your-email@example.com"]

  spec.summary       = "Shared theme for PWindows websites"
  spec.homepage      = "https://github.com/YOUR_ORG/pwindows-theme"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(_(includes|layouts|sass)/|assets/|README|LICENSE)}i)
  end

  spec.add_runtime_dependency "jekyll", "~> 4.4"

  spec.add_development_dependency "bundler", "~> 2.0"
end