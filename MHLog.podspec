Pod::Spec.new do |s|
  s.name             = 'MHLog'
  s.version          = '0.1.0'
  s.summary          = 'A lightweight application logger built on top of SwiftyBeaver.'

  s.description      = <<-DESC
MHLog wraps SwiftyBeaver and provides a small static logging API used by the app.
It writes logs to both the Xcode console and rolling files in the app sandbox.
  DESC

  s.homepage         = 'https://github.com/wangweiqi864-hue/MHLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangweiqi864-hue' => 'wangweiqi864-hue@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/wangweiqi864-hue/MHLog.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'MHLog/Classes/**/*'
  s.dependency 'SwiftyBeaver'
end
