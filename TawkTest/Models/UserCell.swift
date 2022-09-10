//
//  UserCell.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 9/9/2565 BE.
//

import Foundation

enum UserCell: CaseIterable, Equatable {
    case normal(GithubUser)
    case note(GithubUser)
    case inverted(GithubUser)
    case invertedNote(GithubUser)
    
    var cellClass: AnyClass {
        switch self {
        case .normal:
            return NormalCell.self
        case .note:
            return NoteCell.self
        case .inverted:
            return InvertedCell.self
        case .invertedNote:
            return InvertedNoteCell.self
        }
    }
    
    var cellIdentifier: String {
        NSStringFromClass(cellClass)
    }
    
    static var allCases: [UserCell] {
        [
            .normal(.default),
            .note(.default),
            .inverted(.default),
            .invertedNote(.default)
        ]
    }
    
    var user: GithubUser {
        switch self {
        case .normal(let githubUser),
             .note(let githubUser),
             .inverted(let githubUser),
             .invertedNote(let githubUser):
            return githubUser
        }
    }
}
