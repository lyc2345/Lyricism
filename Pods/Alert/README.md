# Alert


[![CI Status](http://img.shields.io/travis/Stan Liu/Alert.svg?style=flat)](https://travis-ci.org/Stan Liu/Alert)
[![Version](https://img.shields.io/cocoapods/v/Alert.svg?style=flat)](http://cocoapods.org/pods/Alert)
[![License](https://img.shields.io/cocoapods/l/Alert.svg?style=flat)](http://cocoapods.org/pods/Alert)
[![Platform](https://img.shields.io/cocoapods/p/Alert.svg?style=flat)](http://cocoapods.org/pods/Alert)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Beware the storyboard in example uses UIStackView, So it can just runs on above iOS 9.0 device and simulator.
But Alert uses Swift 3.0 can run on above iOS 8 device and simulator.

## Requirements

## Installation

Alert is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Alert', :git => 'https://github.com/lyc2345/alert.git'
```

Usage:
```Swift
Import Alert
```
To add a Button to UIAlertController
```Swift

  Alert.with(title: "Title", message: "Message", style: .alert).bind(button: "Button", style:
  .default, completion: {
    (action1) in  

    )}
```

then add a Textfield to UIAlertController
```Swift

  Alert.with(title: "Title", message: "Message", style: .alert).bind(button: "Button", style:
  .default, completion: {
    (action1) in  

    )}.bint(textfield: "Title", placeHolder: "PlaceHolder", secure: false, returnHandler: {
    (textfield1) in
    
    })
```
then present this UIAlertController 
```Swift

  Alert.with(title: "Title", message: "Message", style: .alert).bind(button: "Button", style:
  .default, completion: {
    (action1) in  

    )}.bint(textfield: "Title", placeHolder: "PlaceHolder", secure: false, returnHandler: {
    (textfield1) in
    
    }).show()
```


## Author

Stan Liu, lyc2345@gmail.com

## License

Alert is available under the MIT license. See the LICENSE file for more info.
