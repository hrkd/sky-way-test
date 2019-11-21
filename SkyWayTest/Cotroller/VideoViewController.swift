//
//  ViewController.swift
//
//  Created by 児玉広樹 on 2019/09/03.
//  Copyright © 2019 児玉広樹. All rights reserved.
//

import UIKit
import SkyWay

class VideoViewController: UIViewController {
    public let videoView = VideoView()

    override func loadView() {
        super.loadView()
        self.view = videoView
        videoView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.setup()
    }

    func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension VideoViewController: VideoViewDelegate {
    func videoView(_ videoView: VideoView, didTapDone button: UIButton) {
         NotificationCenter.default.post(name: .closeCall, object: nil)
    }
}
