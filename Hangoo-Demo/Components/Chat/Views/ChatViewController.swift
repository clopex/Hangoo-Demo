//
//  ChatViewController.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import UIKit
import SendBirdSDK
import AVKit

class ChatViewController: UIViewController {
    
    lazy var stackView: UIStackView = {
        let stackV = UIStackView()
        stackV.translatesAutoresizingMaskIntoConstraints = false
        stackV.distribution = .fillProportionally
        stackV.alignment = .fill
        stackV.axis = .horizontal
        return stackV
    }()
    
    lazy var textInfo: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Press and hold to record"
        return label
    }()
    
    lazy var recordButton: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "mic.circle.fill")
        imageView.tintColor = .gray
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(tapRecord(gesture:))))
        return imageView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let audioRecorderHelper = AudioRecordHelper()
    let sendBirdHelper = SendBirdHelper()
    
    var viewModel: ChatViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        userConnect()
        receiveMessages()
        audioRecorderHelper.audioRecorderDelegate = self
    }
    
    init() {
        viewModel  = ChatViewModel.build()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(textInfo)
        view.addSubview(recordButton)
        view.addSubview(tableView)
        
        _ = textInfo.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 38, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = recordButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 32, rightConstant: 24, widthConstant: 50, heightConstant: 50)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: recordButton.topAnchor, right: view.rightAnchor, topConstant: 32, leftConstant: 24, bottomConstant: 0, rightConstant: 24, widthConstant: 0, heightConstant: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(ofType: ChatCell.self)
        tableView.registerCell(ofType: ReceiveChatCell.self)
        audioRecorderHelper.setupAndRequestPermission()
    }
    
    private func userConnect() {
        let userId = UIDevice.current.identifierForVendor!.uuidString
        sendBirdHelper.connect(userId)
        sendBirdHelper.sendBirdDelegate = self
    }
    
    private func userDisconnect() {
        
    }
    
    private func playMedia(_ url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) {
            player.play()
        }
    }
    
    @objc func tapRecord(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            audioRecorderHelper.startRecord()
            textInfo.textColor = .green
            textInfo.text = "Recording..."
        }
        if gesture.state == .ended {
            audioRecorderHelper.sendBirdHelper = sendBirdHelper
            audioRecorderHelper.finishRecording(success: true)
            textInfo.textColor = .black
            textInfo.text = "Press and hold to record"
        }
    }
    
    private func receiveMessages() {
        SBDMain.add(self, identifier: self.description)
    }
    
    func scrollToBottom() {
        tableView.reloadData()
        if viewModel.messages.count == 0 {
            return
        }
        
        let currentRowNumber = self.tableView.numberOfRows(inSection: 0)
        
        self.tableView.scrollToRow(at: IndexPath(row: currentRowNumber - 1, section: 0), at: .bottom, animated: false)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        if let id = message.sender?.userId {
            if id == SBDMain.getCurrentUser()!.userId {
                let cell = tableView.dequeueCell(ofType: ReceiveChatCell.self)
                cell.selectionStyle = .none
                if message is SBDUserMessage {
                    cell.setup(title: message.message)
                } else if message is SBDFileMessage {
                    cell.setup(title: nil)
                }
                return cell
            } else {
                let cell = tableView.dequeueCell(ofType: ChatCell.self)
                cell.selectionStyle = .none
                if message is SBDUserMessage {
                    cell.setup(title: message.message)
                } else if message is SBDFileMessage {
                    cell.setup(title: nil)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = viewModel.messages[indexPath.row]
        if let audioMessage = message as? SBDFileMessage {
            let url = audioMessage.url
            audioRecorderHelper.preparPlay(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension ChatViewController: AudioRecordDelegate {
    func recordStart() {
        
    }
    
    func recordStop() {
        
    }
    
    func recordFinished() {
        audioRecorderHelper.uploadAudioMessage()
    }
    
    func recordFailed() {
        
    }
    
    func permissionGranted() {
        print("permissionGranted")
    }
    
    func permissionDenied() {
        print("permissionDenied")
    }
    
    func audioFailed() {
        print("audioFailed")
    }
}

extension ChatViewController: SBDChannelDelegate {
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        viewModel.messages.append(message)
        scrollToBottom()
    }
}

extension ChatViewController: SandBirdDelegate {
    func fetchAll(_ messages: [SBDBaseMessage]) {
        viewModel.messages.append(contentsOf: messages)
        scrollToBottom()
    }
    
    func loginSuccessful() {
        
    }
    
    func loginFailed() {
        
    }
    
    func uploaded(_ audioFile: SBDBaseMessage) {
        viewModel.messages.append(audioFile)
        scrollToBottom()
    }
    
    
}
