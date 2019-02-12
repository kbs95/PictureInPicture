//
//  PictureViewController.swift
//  PIPView
//
//  Created by Karanbir Singh on 08/02/19.
//  Copyright © 2019 karan. All rights reserved.
//

import UIKit

/*
 The Picture view controller is the superclass which can be inherited by any viewController to
 apply picture in picture mode, it automatically adds a minimize and close button at the top of
 the controller which can be hidden as well for customization.All the transitions to the window
 happens internally, you do not need to call any method, just clicking the minimize button will
 do the trick.
 */

open class PictureViewController: UIViewController {
    
    private lazy var minimizeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Minimize", for: .normal)
        button.setTitle("Maximize", for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()
    
    private lazy var closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()
    
    // override this property, if you want to navigate to root controller on dismiss.
    
    open var popToRootController:Bool{
        return false
    }
    
    // hides navigation bar on minimizing
    
    open var hidesNavigationOnMinimize:Bool{
        return false
    }
    
    private var instanceTimer:Timer?
    private var floatingView:FloatingPictureView? = FloatingPictureView(frame: CGRect.zero)
    

    override open func viewDidLoad() {
        super.viewDidLoad()
        // first thing first, hide the navigation bar
        navigationController?.navigationBar.isHidden = true
        // initially setting up buttons and background image view
        setupViews()
        // start instance timer
        startInstanceGrabTimer()
        // gesture to hide the controls
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideControlsGestureTapped)))
        // hide controls automatically after 2.5 secs
        self.perform(#selector(hideControlButtons), with: nil, afterDelay: 2.5)
    }
    
    // Customization for hover control buttons.
    
    open func customizeMinimizeButton(with title:String?,and image:UIImage?){
        minimizeButton.setTitle(title, for: .normal)
        minimizeButton.setImage(image, for: .normal)
    }
    
    open func customizeMaximizeButton(with title:String?,and image:UIImage?){
        minimizeButton.setTitle(title, for: .selected)
        minimizeButton.setImage(image, for: .selected)
    }
    
    open func customizeCloseButton(with title:String?,and image:UIImage?){
        closeButton.setTitle(title, for: .normal)
        closeButton.setImage(image, for: .normal)
    }
    
    // Control hide gesture action
    
    @objc private func hideControlsGestureTapped(gesture:UITapGestureRecognizer){
        if self.closeButton.alpha == 0{
            self.perform(#selector(hideControlButtons), with: nil, afterDelay: 2.5)
        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControlButtons), object: nil)
        }
        UIView.animate(withDuration: 0.5) {
            self.closeButton.alpha = (self.closeButton.alpha == 0) ? 1 : 0
            self.minimizeButton.alpha = (self.minimizeButton.alpha == 0) ? 1 : 0
        }
    }
    
    // Hiding the controls by setting their alpha to 0
    
    @objc private func hideControlButtons(){
        UIView.animate(withDuration: 0.5, animations: {
            self.closeButton.alpha = 0
            self.minimizeButton.alpha = 0
        })
    }
    
    // placing minimize and close buttom at top left and top right corners respectively
    
    private func setupViews(){
        //view.addSubview(previousViewSnapshot)
        view.addSubview(minimizeButton)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            minimizeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:8),
            minimizeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:0),
        ])
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:-8),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:0),
        ])
        
        minimizeButton.addTarget(self, action: #selector(minimizeAction(sender:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
    }
    
    /*
     starting instance timer and declaring the block so that it holds the instance of controller
     even after the controller is popped or dismissed , so that its view can be accessed
     and placed over main window.
    */
    
    private func startInstanceGrabTimer(){
        instanceTimer = Timer.scheduledTimer(withTimeInterval: 1000, repeats: true, block: { (_) in
            // holding self instance on purpose
            let _ = self
        })
    }
    
    /*
     minimize action will check the state of the button, if it is selected then controller will be maximized
     and pushed to the top controller again. If not then the controller will be popped from screen
     (remember we are holding strong reference using timer, so controller is still in memory) and presen the
     floating view over the window
    */
    
    @objc private func minimizeAction(sender:UIButton){
        if sender.isSelected{
            // maximize the controller
            floatingView?.dismiss()
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                if let rootIsNavigation = topController as? UINavigationController{
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                        self.view.transform = .identity
                        rootIsNavigation.pushViewController(self, animated: true)
                        self.navigationController?.navigationBar.isHidden = true
                    }
                }else{
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    // topController should now be your topmost view controller
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                        self.view.transform = .identity
                        topController.navigationController?.pushViewController(self, animated: true)
                        self.navigationController?.navigationBar.isHidden = true
                    }
                }
            }
        }else{
            // minimizing the controller
            self.navigationController?.navigationBar.isHidden = hidesNavigationOnMinimize
            floatingView?.presentFrom(viewController: self)
            dismissManually()
        }
        sender.isSelected = !sender.isSelected
    }
    
    // On close action, dismiss the floating pictureView and the controller forcefully.
    
    @objc private func closeAction(sender:UIButton){
        self.forceDismiss()
    }
    
    /*
     force dismiss will invalidate the timer which holds strong reference to the viewcontroller
     and allows the controller to be released from memory.
    */
    
    func forceDismiss(){
        floatingView?.dismiss()
        self.instanceTimer?.invalidate()
        self.instanceTimer = nil
        self.dismissManually()
    }
    
    // dismiss the viewController, if it has navigation then pop, if not then just dismiss.
    
    private func dismissManually(){
        if let navigation = self.navigationController{
           let _ = popToRootController ? navigationController?.popToRootViewController(animated: false)?[0] : (navigation.popViewController(animated: false))
        }else{
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    deinit {
        print("Picture controller instance released")
    }
}


extension UIView{
    func applyOriginTransform(with scale:CGFloat){
        let x = frame.origin.x + (self.frame.width * scale)/2
        let y = frame.origin.y + (self.frame.height * scale)/2
        self.layer.position = CGPoint(x: x, y: y)
        self.transform = self.transform.scaledBy(x: scale, y: scale)
    }
}
