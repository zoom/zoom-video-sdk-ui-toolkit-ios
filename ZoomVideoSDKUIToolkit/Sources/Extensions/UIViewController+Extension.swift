//
//  ViewController+Extension.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import UIKit
import ZoomVideoSDK

extension UIViewController {
    @objc func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        // Handling UIViewController's added as subviews to some other views.
        else {
            for view in self.view.subviews {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as! UIViewController
                        return viewController.topMostViewController()
                    }
                }
            }
            return self
        }
    }
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .push
        transition.subtype = .fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .push
        transition.subtype = .fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
    
    func fitLayoutTo(view parentView: UIView) {
        self.view.frame = parentView.bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func alertError(with error: UIToolkitError, dismiss: Bool) {
        let alert = UIAlertController(title: error.description, message: "", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: dismiss ? "Dismiss" : "Ok", style: .default, handler: {_ in
            if dismiss {
                ErrorManager.shared().getDelegate()?.onViewDismissed()
                self.dismiss(animated: true)
            }
        })
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isAlertControlPresenting() -> Bool {
        if self.presentedViewController is UIAlertController {
            return true
        } else {
            return false
        }
    }
    
    func hideKeyboardWhenClickedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
