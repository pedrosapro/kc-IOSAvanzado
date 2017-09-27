//
//  String+Image.swift
//  MadridShopping
//
//  Created by Pedro Sánchez Castro on 26/9/17.
//  Copyright © 2017 pedrosapro. All rights reserved.
//

import UIKit

extension String {
    func loadImage(into imageView: UIImageView) {
        let queue = OperationQueue()
        queue.addOperation {
            if let url = URL(string: self),
                let data = NSData(contentsOf: url),
                let image = UIImage(data: data as Data) {
                
                OperationQueue.main.addOperation {
                    imageView.image = image
                }
            }
        }
    }
}