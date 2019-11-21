//
//  ViewController.swift
//
//  Created by 児玉広樹 on 2019/09/04.
//  Copyright © 2019 児玉広樹. All rights reserved.
//

import UIKit
import SkyWay
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var peer: SKWPeer?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?
    private let skyWayTestUIView = SkyWayTestUIView()

    var peerIds:[String] = ["aaa"]
    var video:VideoViewController?

    override func loadView() {
        super.loadView()
        self.view = skyWayTestUIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        skyWayTestUIView.tableView.dataSource = self
        skyWayTestUIView.tableView.delegate = self
        self.setup()
        self.video = R.storyboard.main.video()
        
        //Observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: .closeCall,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func userDefaultsDidChange() {
        self.endCall()
    }

    @objc private func audioRouteChanged() {
        if AVAudioSession.sharedInstance().currentRoute.outputs[0].portType == .builtInReceiver {
            self.enableSpeaker()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func changeConnectionStatusUI(connected:Bool){
        if connected {
        }else{
        }
    }
    
    func appearTalk(targetPeerId: String){
        if let video = self.video as? VideoViewController {
            self.present(video, animated: true, completion: nil)
            self.localStream?.addVideoRenderer(video.videoView.localStreamView, track: 0)
            self.call(targetPeerId: targetPeerId)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("return count \(self.peerIds)")
        return self.peerIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("return cell \(self.peerIds) \(indexPath.row)")
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.peerIds[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.appearTalk(targetPeerId: self.peerIds[indexPath.row])
    }
}

// MARK: setup skyway
extension ViewController{
    func setup(){
        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            print("Not set apikey or domain")
            return
        }
        
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain
        
        peer = SKWPeer(options: option)
        
        if let _peer = peer{
            self.setupStream(peer: _peer)
            self.setupPeerCallBacks(peer: _peer)
        }else{
            print("failed to create peer setup")
        }
    }
    
    func setupStream(peer:SKWPeer){
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        self.localStream = SKWNavigator.getUserMedia(constraints)
    }
    
    func call(targetPeerId:String){
        let option = SKWCallOption()
        
        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
    }
    
    func endCall(){
        self.mediaConnection?.close()
        self.changeConnectionStatusUI(connected: false)
    }
    
    func enableSpeaker() {
        //enable speaker
        do {
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.voiceChat)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            //error handling
        }
    }
}

extension ViewController {
    func setupPeerCallBacks(peer:SKWPeer){
        // MARK: PEER_EVENT_ERROR
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            if let error = obj as? SKWPeerError{
                print("\(error)")
            }
        })
        
        // MARK: PEER_EVENT_OPEN
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            if let myPeerId = obj as? String{
                DispatchQueue.main.async {
                    self.skyWayTestUIView.myPeerId.text = "your peerId: \(myPeerId)"
                    //self.myPeerIdLabel.textColor = UIColor.darkGray
                    
                    peer.listAllPeers({ (peers) -> Void in
                        if let connectedPeerIds = peers as? [String]{
                            self.peerIds = connectedPeerIds.filter({ (connectedPeerId) -> Bool in
                                return connectedPeerId != myPeerId
                            })
                            if self.peerIds.count == 0 {self.peerIds = ["aaa"]}
                            print(self.peerIds)
                            self.skyWayTestUIView.tableView.reloadData()
                        }else{
                            print("nil")
                        }
                    })
                }
                print("your peerId: \(myPeerId)")
            }
        })

        // MARK: PEER_EVENT_CONNECTION
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
            if let connection = obj as? SKWMediaConnection, let video = self.video as? VideoViewController{
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.localStream)

                self.present(video, animated: true, completion: nil)
                self.localStream?.addVideoRenderer(video.videoView.localStreamView, track: 0)
            }
        })
    }
    
    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
        // MARK: MEDIACONNECTION_EVENT_STREAM
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                DispatchQueue.main.async {
                    //self.targetPeerIdLabel.text = self.remoteStream?.peerId
                    //self.targetPeerIdLabel.textColor = UIColor.darkGray
                    if let video = self.video {
                        self.remoteStream?.addVideoRenderer(video.videoView.remoteStreamView, track: 0)
                    }
                }
                self.changeConnectionStatusUI(connected: true)
            }
        })

        // MARK: MEDIACONNECTION_EVENT_CLOSE
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            if let _ = obj as? SKWMediaConnection, let videoView = self.video as? VideoViewController{
                DispatchQueue.main.async {
                    self.remoteStream = nil
                    self.mediaConnection = nil
                    
                    //disable speaker
                    do {
                        try AVAudioSession.sharedInstance().setActive(false)
                    } catch {
                        //error handling
                    }
                }
                self.changeConnectionStatusUI(connected: false)
                videoView.close()
            }
        })
    }
}
