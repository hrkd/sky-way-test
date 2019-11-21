//
//  VideoView.swift
//
//  Created by 児玉広樹 on 2019/09/11.
//  Copyright © 2019 児玉広樹. All rights reserved.
//

import UIKit
import SkyWay

class VideoView: BaseUIView {
    weak var delegate: VideoViewDelegate?
    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.videoView(self, didTapDone: sender)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol VideoViewDelegate: class {
    func videoView(_ videoView: VideoView, didTapDone button: UIButton)
}
