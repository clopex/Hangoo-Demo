//
//  SandBirdHelper.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import Foundation
import SendBirdSDK

class SendBirdHelper: NSObject {
    
    func login(_ userId: String) {
        SBDMain.connect(withUserId: userId) { user, error in
            if error == nil {
                //error
            } else {
                print("user connected")
            }
        }
    }
}

protocol SandBirdDelegate: AnyObject {
    func loginSuccessful()
    func loginFailed()
}
