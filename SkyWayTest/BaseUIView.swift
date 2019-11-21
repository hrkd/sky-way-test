//
//  BaseUIView.swift
//
//  Created by 児玉広樹 on 2019/09/11.
//  Copyright © 2019 児玉広樹. All rights reserved.
//

import UIKit

class BaseUIView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private var className: String {
        get {
            return String(describing: type(of: self)) // ClassName
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    private func loadNib() {
        let view = Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}
