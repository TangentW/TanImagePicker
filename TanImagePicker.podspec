Pod::Spec.new do |s|
  s.name             = 'TanImagePicker'
  s.version          = '0.2.3'
  s.summary          = 'Simple image picker, support iCloud.'
 
  s.homepage         = 'https://github.com/TangentW/TanImagePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tangent' => '805063400@qq.com' }
  s.source           = { :git => 'https://github.com/TangentW/TanImagePicker.git', :tag => s.version.to_s }
  s.platform         = :ios
  s.ios.deployment_target = "9.0"
 
  s.source_files = 'TanImagePicker/TanImagePicker/Classes/**/*.swift'
  s.resources = "TanImagePicker/TanImagePicker/*.{xcassets,lproj}"
  s.frameworks  = "UIKit", "Photos"
end