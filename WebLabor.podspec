Pod::Spec.new do |s|
  s.name             = "WebLabor"
  s.version          = "0.1.1"
  s.summary          = "A javascript worker lives in iOS/OSX WebView"

  s.description      = <<-DESC
A javascript worker lives in iOS/OSX WebView.
                       DESC

  s.homepage         = "https://github.com/huxia/WebLabor"
  s.license          = 'MIT'
  s.author           = { "huxia" => "huizhe.xiao@gmail.com" }
  s.source           = { :git => "https://github.com/huxia/WebLabor.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/huizhe'

  s.ios.deployment_target     = '7.0'
  s.osx.deployment_target     = '10.9'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'WebLabor' => ['Pod/Assets/*']
  }
  s.resources = "Pod/Assets/*"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'UIKit'
  s.osx.frameworks = 'WebKit'

  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'WebViewJavascriptBridge', '~> 4.1.4'
  s.dependency 'RegexKitLite-NoWarning', '~> 1.1.0'
end
