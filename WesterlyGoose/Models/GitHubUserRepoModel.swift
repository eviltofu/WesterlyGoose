//
//  GitHubUserRepoModel.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 28/10/20.
//

import Foundation

struct GitHubUserRepoModel: Codable, Identifiable {
    var id: Int
    var name: String?
    var repoDescription: String?
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case repoDescription = "description"
    }
    func nameString() -> String {
        return name ?? "No name"
    }
    func repoDescriptionString() -> String {
        return repoDescription ?? "No description"
    }
}
