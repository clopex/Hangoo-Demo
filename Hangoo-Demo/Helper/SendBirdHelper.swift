//
//  SandBirdHelper.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import Foundation
import SendBirdSDK

class SendBirdHelper: NSObject {
    let channelUrl = "testchannelurl"
    
    var groupChannel: SBDOpenChannel?
    weak var sendBirdDelegate: SandBirdDelegate?
    
    func connect(_ userId: String) {
        SBDMain.connect(withUserId: userId) { [weak self] user, error in
            if error != nil {
                //error
                print("error connect \(error?.localizedDescription)")
            } else {
                print("user connected")
                self?.enterChannel()
            }
        }
    }
    
    func disconnect() {
        SBDMain.disconnect {
            //disconnected
        }
    }
    
    private func enterChannel() {
        SBDOpenChannel.getWithUrl(channelUrl) { channel, error in
            if error != nil {
                print("channel error")
            } else {
                channel?.enter(completionHandler: { [weak self] err in
                    if err != nil {
                        
                        print("error enter channel")
                    } else {
                        self?.groupChannel = channel
                        self?.loadMessages()
                        print("user entered channel")
                    }
                })
            }
        }
    }
    
    func exitChannel() {
        SBDOpenChannel.getWithUrl(channelUrl) { channel, error in
            if error == nil {
                channel?.exitChannel(completionHandler: { err in
                    //user exits
                })
            }
        }
    }
    
    func loadMessages() {
        guard let channel = groupChannel else {return}
        let timestamp = Int64.max
        
        channel.getPreviousMessages(byTimestamp: timestamp, limit: 50, reverse: false) { [weak self] messages, error in
            if error == nil {
                guard let messages = messages else {return}
                self?.sendBirdDelegate?.fetchAll(messages)
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func sendVoiceMessage(_ data: Data) {
        guard let channel = groupChannel else {return}
        channel.sendFileMessage(withBinaryData: data, filename: "message_recording.m4a", type: "audio/m4a", size: UInt(data.count), data: nil) { [weak self] fileMsg, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                guard let message = fileMsg else {return}
                self?.sendBirdDelegate?.uploaded(message)
            }
        }
    }
    //channel.sendFileMessage(withBinaryData: data, filename: "message_recording.m4a", type: "audio/m4a", size: UInt(data.count), data: nil, completionHandler: { message, error in
    
    //    func sendVoiceMessage(_ data: Data) {
    //        guard let channel = groupChannel else {return}
    //        let params = SBDFileMessageParams.init(file: data)
    //        params?.file = data
    //        params?.mimeType = "audio/m4a"
    //        channel.sendFileMessage(with: params!) {[weak self] fileMsg, error in
    //            if error != nil {
    //                print(error?.localizedDescription)
    //            } else {
    //                guard let message = fileMsg else {return}
    //                self?.sendBirdDelegate?.uploaded(message)
    //            }
    //        }
    //    }
    
    func sendMsg() {
        guard let channel = groupChannel else {return}
        channel.sendUserMessage("Test naki") { message, error in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
    }
}

protocol SandBirdDelegate: AnyObject {
    func loginSuccessful()
    func loginFailed()
    func uploaded(_ audioFile: SBDBaseMessage)
    func fetchAll(_ messages: [SBDBaseMessage])
}
