//
//  FloatingPictureView.swift
//  PIPView
//
//  Created by Karanbir Singh on 10/02/19.
//  Copyright © 2019 karan. All rights reserved.
//

import UIKit

/*
 FloatingPictureView handles the picture controller's view after being dismissed, it keeps floating over
 the main window and has pan gesture to move it anywhere on screen.
 */

internal class FloatingPictureView:UIView{
    
    // shared instance
    //    static let shared = FloatingPictureView(frame: CGRect.zero)
    
    private let keyWindow = (UIApplication.shared.delegate)?.window
    private var panGestureRecognizer = UIPanGestureRecognizer()
    
    // auto repositioning point, as it says, used to auto position the view if user places it in middle or out of the screen.
    
    private let autoRepositionPoint = CGPoint(x:  UIScreen.main.bounds.width/2, y:  UIScreen.main.bounds.height)
    private let viewInsetsX:CGFloat = 20
    private let viewInsetsY:CGFloat = 40
    
    // computed properties
    
    private var size:CGSize{
        return CGSize(width: 70 * Int(UIScreen.main.scale), height: 100 * Int(UIScreen.main.scale))
    }
    private var startingPosition:CGPoint{
        return CGPoint(x: UIScreen.main.bounds.width - (size.width + viewInsetsX), y: UIScreen.main.bounds.height - (size.height + viewInsetsY))
    }
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 25.0
    private var fillColor: UIColor = .black // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // setup shadow to make it look good and add gesture for movements.
        self.addShadow(to: self)
        panGestureRecognizer.addTarget(self, action: #selector(handlePan(gesture:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // tap gesture handler
    
    @objc private func handlePan(gesture:UIPanGestureRecognizer){
        let panTranslation = gesture.translation(in:keyWindow!)
        if gesture.state == .ended{
            // animate to desired position after user ends the gesture
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.center = self.findAutoRespositionPoint()
            }, completion: nil)
        }
        if gesture.state == .changed{
            // position the view accordingly
            self.center = CGPoint(x: self.center.x + panTranslation.x, y: self.center.y + panTranslation.y)
        }
        gesture.setTranslation(CGPoint.zero, in: keyWindow!)
    }
    
    // calculating the final postion for view when user ends the gesture
    
    private func findAutoRespositionPoint()->CGPoint{
        var finalPosition = CGPoint()
        let upperScreenBound = (autoRepositionPoint.y - (self.frame.height/2 + viewInsetsY))
        let lowerScreenBound = (self.frame.height/2 + viewInsetsY)
        finalPosition.x = (self.center.x > autoRepositionPoint.x) ?  ((autoRepositionPoint.x * 2) - (self.frame.width/2 + viewInsetsX)) : (self.frame.width/2 + viewInsetsX)
        finalPosition.y = self.center.y
        
        if finalPosition.y < lowerScreenBound{
            finalPosition.y = lowerScreenBound
        }else if finalPosition.y > upperScreenBound{
            finalPosition.y = upperScreenBound
        }
        return finalPosition
    }
    
    // present the floating view
    
    func presentFrom(viewController:UIViewController){
        
        guard let controllerView = viewController.view else {  print("cant get view for the controller"); return }
        
        // add the controller's view to picture view and add them to window so that they float above the main window
        
        self.addSubview(controllerView)
        self.frame = CGRect(x: startingPosition.x, y: startingPosition.y, width: size.width, height: size.height)
        keyWindow??.addSubview(self)
        
        controllerView.applyOriginTransform(with: 0.6)
        controllerView.frame.size = size
        self.addShadow(to: controllerView)
        
        // animate the view for better user experience
        
        self.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    // dismissing the floating view,revert radius back to 0 after controller is maximized
    
    func dismiss(){
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.subviews.forEach({ (view) in
                view.layer.cornerRadius = 0
            })
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    // adding corner radius and shadow to view
    
    func addShadow(to view:UIView?){
        view?.layer.shadowOffset = CGSize(width: 1, height: 1)
        view?.layer.shadowRadius = 3
        view?.layer.shadowOpacity = 0.75
        view?.layer.cornerRadius = 10
    }
    
    deinit {
        print("floating view instance released")
    }
}

