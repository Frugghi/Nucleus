Pod::Spec.new do |spec|
  spec.name         = 'Nucleus'
  spec.version      = '0.1.0'
  spec.summary      = 'A Swift feed reader.'
  spec.homepage     = 'https://github.com/Frugghi/Nucleus'
  spec.license      = 'MIT'
  spec.authors      = { 'Tommaso Madonia' => 'tommaso@madonia.me' }
  spec.source       = { :git => 'https://github.com/Frugghi/Nucleus.git' }

  spec.requires_arc = true
  spec.platform = :ios, '8.0'
  spec.source_files = 'Nucleus'
end