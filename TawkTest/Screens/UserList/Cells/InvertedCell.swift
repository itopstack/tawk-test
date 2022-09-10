//
//  InvertedCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

final class InvertedCell: NormalCell {
    override func updateAvatarImage(from data: Data?) {
        baseView.avatarMode = .inverted
        baseView.updateAvatarImage(from: data)
    }
}
