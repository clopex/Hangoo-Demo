//
//  ChatViewModel.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import Foundation
import SendBirdSDK

class ChatViewModel {
    
    var messages: [SBDBaseMessage] = []
    
    static func build() -> ChatViewModel {
        return ChatViewModel()
    }
}
