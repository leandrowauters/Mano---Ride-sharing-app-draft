//
//  IBDesignableViews.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.cornerRadius = bounds.height / 2.0
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        
        textAlignment = .center
        autocorrectionType = .no
        
        if (self.isSecureTextEntry) {
            self.textColor = UIColor.black
        } else {
           font = UIFont(name: "Arial Rounded MT Bold", size: 22)
            textColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        }
    }
}

@IBDesignable
class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFill
        layer.cornerRadius = bounds.height / 2.0
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        clipsToBounds = true
        
    }
}

@IBDesignable
class CircularButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFill
        layer.cornerRadius = bounds.height / 2.0
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        clipsToBounds = true
        
    }
}
@IBDesignable
class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.cornerRadius = bounds.height / 2.0
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
    
    }
}
@IBDesignable
class LogoHeaderDriver: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        image = UIImage(named: "ManoLogo1")
        backgroundColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
    }
}

@IBDesignable
class LogoHeaderRider: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        image = UIImage(named: "ManoLogo1")
        backgroundColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
    }
}


@IBDesignable
class SubHeaderRider: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
    }
    
}
@IBDesignable
class BorderedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
    }
}

@IBDesignable
class RoundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 30.0
        clipsToBounds = true
    }
}

@IBDesignable
class CircularView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        clipsToBounds = true
    }
}

@IBDesignable
class BlueBorderedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 3
        layer.borderColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
    }
}

@IBDesignable
class RoundViewWithBorder: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 30.0
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        clipsToBounds = true
    }
}

@IBDesignable
class RoundDatePicker: UIDatePicker {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 30.0
        layer.borderWidth = 3
        layer.borderColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        setValue( #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1), forKeyPath: "textColor")
        clipsToBounds = true
    }
}
