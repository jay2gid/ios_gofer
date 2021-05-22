//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit

//Global variables
struct ConstantGlobal {
  
    static let blue = UIColor.rbg(r: 129, g: 144, b: 255)
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
    static let Border = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
    static let DarkGray = UIColor(red: 0.335, green: 0.338, blue: 0.33, alpha: 1)
    static let Gray =  UIColor(red: 0.629, green: 0.629, blue: 0.629, alpha: 1)
    static let DarkBlack = UIColor(red: 0.114, green: 0.117, blue: 0.11, alpha: 1)
    
    
    
    struct Color {
        static let Primary = UIColor.rbg(r: 20, g: 189, b: 93)
        static let Border = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        static let DarkGray = UIColor(red: 0.335, green: 0.338, blue: 0.33, alpha: 1)
        static let Gray =  UIColor(red: 0.629, green: 0.629, blue: 0.629, alpha: 1)
        static let DarkBlack = UIColor(red: 0.114, green: 0.117, blue: 0.11, alpha: 1)
    }
    
    struct Notifier {
        
        static let refreshPost = "refreshPost"
    }
}



//Extensions
extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

//Enums
enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}

enum MessageType {
    case photo
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}
