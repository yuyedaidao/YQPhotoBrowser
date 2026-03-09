# YQPhotoBrowser

![gif](https://github.com/yuyedaidao/YQPhotoBrowser/blob/develop/photobrowser.gif)

### INSTALL

#### CocoaPods
```ruby
pod 'YQPhotoBrowser', :git => "https://github.com/yuyedaidao/YQPhotoBrowser.git"
```

#### Swift Package Manager
Xcode:
1. File -> Add Package Dependencies...
2. Enter `https://github.com/yuyedaidao/YQPhotoBrowser.git`
3. Select `YQPhotoBrowser` product

`Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yuyedaidao/YQPhotoBrowser.git", from: "0.5.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["YQPhotoBrowser"]
    )
]
```
