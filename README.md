# BilibiliKit

3rd-party implementation of core bilibili functionalities in Swift.

[![GitHub (pre-)release](https://img.shields.io/github/release/ApolloZhu/BilibiliKit/all.svg)](https://github.com/ApolloZhu/BilibiliKit/releases) [![Actions Status](https://github.com/ApolloZhu/BilibiliKit/workflows/Build/badge.svg)](https://github.com/ApolloZhu/BilibiliKit/actions) [![Swift 5.0](https://img.shields.io/badge/Swift-5.0-ffac45.svg)](https://developer.apple.com/swift/) [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) [![MIT License](https://img.shields.io/github/license/ApolloZhu/BilibiliKit.svg)](https://github.com/ApolloZhu/BilibiliKit/blob/master/LICENSE) [![Documentation](https://apollozhu.github.io/BilibiliKit/badge.svg)](https://apollozhu.github.io/BilibiliKit) [![BCH compliance](https://bettercodehub.com/edge/badge/ApolloZhu/BilibiliKit?branch=master)](https://bettercodehub.com/) [![Maintainability](https://api.codeclimate.com/v1/badges/9d38e10afb019c8c2f9e/maintainability)](https://codeclimate.com/github/ApolloZhu/BilibiliKit/maintainability)

## Install

### Swift Package Manager

In `Package.swift`, add to your package's `dependencies` array:

```swift
.package(url: "https://github.com/ApolloZhu/BilibiliKit", from: "3.1.2"),
```

then add either `BilibiliKit` or `BilibiliKitDYLIB` (especially if you share this between main app and app extensions) as your `targets`' `dependencies`.

### CocoaPods

In `Podfile` add:

```ruby
pod 'BilibiliKit', '~> 3.1.2'
```

then run a `pod install` inside your terminal, or from CocoaPods.app.
