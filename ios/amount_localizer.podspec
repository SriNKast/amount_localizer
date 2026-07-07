Pod::Spec.new do |s|
  s.name             = 'amount_localizer'
  s.version          = '0.1.0'
  s.summary          = 'Reads the device Region setting for locale-aware amount formatting.'
  s.description      = <<-DESC
Bridges the iOS Region setting (which drives the numeric-keyboard decimal
key) to Flutter, since PlatformDispatcher only reports the language locale.
                       DESC
  s.homepage         = 'https://github.com/SriNKast/amount_localizer'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Sri Murthi' => 'murthi@kastcard.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.0'
end
