//
//  Video.swift
//  YouTubeApp
//
//  Created by Domini Valencia on 1/21/25.
//

import Foundation

// MARK: - Models
struct Video: Decodable {
    let videoId: String
    let title: String
    let thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case snippet
    }

    enum IdKeys: String, CodingKey {
        case videoId
    }

    enum SnippetKeys: String, CodingKey {
        case title
        case thumbnails
    }

    enum ThumbnailKeys: String, CodingKey {
        case medium
    }

    enum MediumKeys: String, CodingKey {
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try container.nestedContainer(keyedBy: IdKeys.self, forKey: .id)
        let snippetContainer = try container.nestedContainer(keyedBy: SnippetKeys.self, forKey: .snippet)
        let thumbnailContainer = try snippetContainer
            .nestedContainer(keyedBy: ThumbnailKeys.self, forKey: .thumbnails)
            .nestedContainer(keyedBy: MediumKeys.self, forKey: .medium)

        videoId = try idContainer.decode(String.self, forKey: .videoId)
        title = try snippetContainer.decode(String.self, forKey: .title)
        thumbnailURL = try thumbnailContainer.decode(String.self, forKey: .url)
    }
}


struct VideoResponse: Decodable {
    let items: [Video]

    enum CodingKeys: String, CodingKey {
        case items
    }
}


