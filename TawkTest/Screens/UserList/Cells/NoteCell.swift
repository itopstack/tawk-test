//
//  NoteCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import UIKit

class NoteCell: NormalCell {
    override func setupView() {
        super.setupView()
        
        let noteImage = UIImage(systemName: "note")
        let noteImageView = UIImageView(image: noteImage)
        noteImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteImageView)
        
        NSLayoutConstraint.activate([
            noteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            noteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
