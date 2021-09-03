//
//  ChatCell.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var audioImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(title: String?) {
        if let title = title {
            titleLabel.text = title
            audioImage.isHidden = true
        } else {
            titleLabel.text = "Audio file"
            audioImage.isHidden = false
        }
    }
}
