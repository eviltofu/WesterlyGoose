//
//  GitHubUserModel.swift
//  WesterlyGoose
//
//  Created by Jerome Chan on 27/10/20.
//

import Foundation

struct GitHubUser: Codable {
    var name: String?
    var userName: String?
    var imageURL: String?
    var email: String?
    enum CodingKeys: String, CodingKey  {
        case name
        case userName = "login"
        case imageURL = "avatar_url"
        case email
    }
    func userNameString() -> String {
        return userName ?? ""
    }
    func imageURLString() -> String {
        return imageURL ?? ""
    }
    func emailString() -> String {
        return email ?? ""
    }
    func nameString() -> String {
        return name ?? ""
    }
}
