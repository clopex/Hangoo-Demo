//
//  UITableViewGenerics.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    
    func dequeueCell<T: UITableViewCell>(ofType type: T.Type) -> T     {
        let cellName = T.reuseIdentifier
        
        return dequeueReusableCell(withIdentifier: cellName) as! T
    }
    
    func registerCell<T: UITableViewCell>(ofType type: T.Type) {
        let cellName = T.reuseIdentifier //String(describing: T.self)
        
        if Bundle.main.path(forResource: cellName, ofType: "nib") != nil {
            let nib = UINib(nibName: cellName, bundle: Bundle.main)
            
            register(nib, forCellReuseIdentifier: cellName)
        } else {
            register(T.self, forCellReuseIdentifier: cellName)
        }
    }
}
