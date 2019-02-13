# PictureInPictureVC
A UiViewController class with feature of minimise and maximise, just like the picture in picture mode in AVPlayerViewController in iOS.

# Usage
- Create your viewController using storyboard or programatically.
- Inherit the `PictureViewController`
```swift
class yourViewController:PictureViewController{
  override func viewDidLoad(){
    super.viewDidLoad()
  }
}
```
- Always push the PictureViewController inherited vc
```swift
 self.navigationController?.pushViewController(yourViewController,animated:true)
 ```
- Thats it you can now minimize and maximize this controller

# Customization
- Can customize control buttons
```swift
 // Minimize button
 self.customizeMinimizeButton(with title:String?,and image:UIImage?)
 // Maximize button
 self.customizeMaximizeButton(with title:String?,and image:UIImage?)
 // Close button
 self.customizeCloseButton(with title:String?,and image:UIImage?)
 ```
- override properties
```swift
 // override this property, if you want to navigate to root controller on minimize.
 open var popToRootController:Bool{
     return false
 }
 // hides navigation bar on minimizing
 open var hidesNavigationOnMinimize:Bool{
     return false
 }
```
 
