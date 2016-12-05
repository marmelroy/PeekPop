![PeekPop - backwards-compatible peek and pop in Swift](https://cloud.githubusercontent.com/assets/889949/13729164/1df56d7a-e92f-11e5-8190-4188f7e848aa.png)

[![Build Status](https://travis-ci.org/marmelroy/PeekPop.svg?branch=master)](https://travis-ci.org/marmelroy/PeekPop) [![Version](http://img.shields.io/cocoapods/v/PeekPop.svg)](http://cocoapods.org/?q=PeekPop)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PeekPop
Peek and Pop is a great new iOS feature introduced with iPhone 6S and 6S+ that allows you to easily preview content using 3D touch.

Sadly, almost 60% of iOS users are on older devices. 

PeekPop is a Swift framework that brings backwards-compatibility to Peek and Pop.  

<p align="center"><img src="https://cloud.githubusercontent.com/assets/1930855/19472280/3a1e7eac-9559-11e6-93e3-ecc35e60699f.gif" width="242" height="425"/></p>

## Features


              |  Features
--------------------------|------------------------------------------------------------
:star2: | Uses Apple's beautiful peek and pop interaction for devices with 3D touch.
:point_up_2: | Custom Pressure-sensitive tap recognition for older devices.
:heartpulse: | Faithful recreation of the peek and pop animation on older devices. 
:iphone: | Almost identical API to Apple's.
:eight: | Runs on all iOS8+ devices.

Missing features:
- Support for peek and pop preview actions in devices that don't have 3D touch. 

## Usage

Import PeekPop at the top of the Swift file.

```swift
import PeekPop
```

Create a PeekPop object, register your view controller for handling the peek and specify the source view. You will also need to declare that your view controller will conform to the PeekPopPreviewingDelegate protocol.

```swift
class MyViewController: UIViewController, PeekPopPreviewingDelegate {
    
    var peekPop: PeekPop?
        
    override func viewDidLoad() {
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView)
    }
```

PeekPopPreviewingDelegate requires implementing two simple functions. You will need to tell it what view controller to present for peeking purposes with: 
```swift
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController?
```

...and you will need to tell it how to commit the preview view controller at the end of the transition with: 
```swift
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController)
```

## How does it work? 

In devices without 3D touch, PeekPop recognizes pressure on the screen by monitoring significant changes in UITouch's majorRadius value. 

It assumes that by pressing harder on your iPhone, more of the surface area of your finger is in contact with the screen. This is true in the majority of cases. 

### Setting up with [CocoaPods](http://cocoapods.org/?q=PeekPop)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'PeekPop', '~> 1.0'
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PeekPop into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/PeekPop"
```

## Inspiration
- [http://krakendev.io/peek-pop/](http://krakendev.io/peek-pop/)
- [http://flexmonkey.blogspot.fr/2015/10/the-plum-o-meter-weighing-plums-using.html](http://flexmonkey.blogspot.fr/2015/10/the-plum-o-meter-weighing-plums-using.html)
- [https://github.com/b3ll/Pseudo3DTouch](https://github.com/b3ll/Pseudo3DTouch)

