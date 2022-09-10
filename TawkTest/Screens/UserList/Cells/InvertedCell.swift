//
//  InvertedCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

final class InvertedCell: NormalCell {
    override func updateAvatarImage(from data: Data?) {
        normalView.avatarMode = .inverted
        normalView.updateAvatarImage(from: data)
    }
}
