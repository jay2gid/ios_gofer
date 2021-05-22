//
//  UIViewExtension.swift
//  FansKick
//
//  Created by FansKick-Raj on 11/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

extension UIView {
    
//    @IBInspectable var corner: CGFloat {
//        get {
//            return self.layer.cornerRadius
//        }
//        set {
//
//            self.layer.cornerRadius = newValue
//            self.clipsToBounds = true
//        }
//    }
    func cardShape(_ color: UIColor = UIColor.darkGray) {
        
        self.layer.cornerRadius = 2.0
        self.clipsToBounds = true

        self.aroundShadow(color)
    }
    
    func shadow(_ color: UIColor = UIColor.darkGray) {
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    func aroundShadow(_ color: UIColor = UIColor.darkGray) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
    
    func setBorder(_ color: UIColor, borderWidth: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    func vibrate() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.02
        animation.repeatCount = 2
        animation.speed = 0.5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2.0, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func shake() {
        self.transform = CGAffineTransform(translationX: 5, y: 5)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func setTapperTriangleShape(_ color:UIColor) {
        // Build a triangular path
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0,y: 0))
        path.addLine(to: CGPoint(x: 40,y: 40))
        path.addLine(to: CGPoint(x: 0,y: 100))
        path.addLine(to: CGPoint(x: 0,y: 0))
        
        // Create a CAShapeLayer with this triangular path
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        // Mask the view's layer with this shape
        self.layer.mask = mask
        
        self.backgroundColor = color
        
        // Transform the view for tapper shape
        self.transform = CGAffineTransform(rotationAngle: CGFloat(270) * CGFloat(Double.pi / 2) / 180.0)
    }
    
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) throws {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)),
        mask = CAShapeLayer()
        
        mask.path = path.cgPath
        self.layer.mask = mask
        self.layer.masksToBounds=true
    }
    
    func roundCornerWithBorder(cornerRadius : CGFloat = 5.0,maskToBound : Bool = true,borderWidth : CGFloat = 0.5,borderColor : UIColor = UIColor.black) throws {
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = maskToBound
        self.layer.borderWidth = borderWidth
        self.layer.borderColor =  borderColor.cgColor
    }
    
    func toCircle() throws {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
    func cornerRadius(cornerRadius : CGFloat) throws {
        self.layer.cornerRadius = cornerRadius
    }
    
    func masksToBounds(maskToBound : Bool) throws {
        self.layer.masksToBounds = maskToBound
    }
    
    func removeBorder() throws {
        self.layer.borderWidth = 0.0
    }
    
    func shadowEffet() throws {
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero;
        self.layer.shadowOpacity = 0.5
    }
    
    func backgroundFade(alpha : CGFloat = 0.3) throws {
        self.backgroundColor = UIColor.black.withAlphaComponent(alpha)
    }
    
    func fadeIn(withDuration duration: TimeInterval = 0.5) throws {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut(withDuration duration: TimeInterval = 0.5) throws {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func viewAnimationEnabled(_bool: Bool) throws {
        UIView.setAnimationsEnabled(_bool)
    }
    
    func addTapToDismissView() throws {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewOnTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissViewOnTap() throws {
        try? self.fadeOut(withDuration: 0.5)
    }
    
    func animateHide() throws {
        
        let animationDuration = 0.35
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.transform = self.transform.scaledBy(x: 0.001, y: 0.001)
        }) { (completion) -> Void in
            self.removeFromSuperview()
        }
    }
    
    func animateShow(view : UIView) throws {
        
        let animationDuration = 0.2
        self.addSubview(view)
        view.transform = view.transform.scaledBy(x: 0.001, y: 0.001)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.transform = CGAffineTransform.identity
        })
    }
    
}
extension UILabel {
    
    func addTapToDismissLabel()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.topMostController(), action: #selector(dismissLabelOnTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissLabelOnTap()  {
        
        
        self.removeFromSuperview()
    }
    public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController
        {
            return topViewController(presented)
        }
        return base
    }
    
    //    func set(html : String) throws {
    //        do {
    //            guard let htmlData = html.data(using: String.Encoding.utf8) else { return }
    //            self.attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
    //            self.adjustsFontSizeToFitWidth = true
    //            self.lineBreakMode = .byTruncatingTail
    //        }
    //        catch {
    //            print("Unable to parse label text: \(error)")
    //        }
    //    }
}
