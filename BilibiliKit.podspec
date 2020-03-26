Pod::Spec.new do |s|
  s.name         = "BilibiliKit"
  s.version      = "3.1.2"
  s.summary      = "bilibili APIs in Swift."
  s.description  = <<-DESC
    3rd-party implementation of core bilibili functionalities in Swift.
  DESC
  s.homepage     = "https://github.com/ApolloZhu/BilibiliKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Apollo Zhu" => "public-apollonian@outlook.com" }
  s.social_media_url   = "https://twitter.com/zhuzhiyu_"
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/ApolloZhu/BilibiliKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.swift_versions = ['4.0', '4.2', '5.0', '5.1', '5.2']
  s.frameworks  = "Security"
end
