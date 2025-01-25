//
//  Comment.swift
//  YouTubeApp
//
//  Created by Domini Valencia on 1/25/25.
//

import Foundation

struct CommentThreadResponse: Decodable {
    let items: [CommentThread]
}

struct CommentThread: Decodable {
    let id: String
    let snippet: CommentThreadSnippet
}

struct CommentThreadSnippet: Decodable {
    let topLevelComment: TopLevelComment
}

struct TopLevelComment: Decodable {
    let id: String
    let snippet: CommentSnippet
}

struct CommentSnippet: Decodable {
    let authorDisplayName: String
    let textDisplay: String
    let likeCount: Int
    let publishedAt: String
}
