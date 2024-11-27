//
//  Notifications.swift
//  DeviceDetector
//
//  Created by Bobby on 11/25/24.
//

import Foundation

struct AppNotification: Decodable {
    let userId: String
    let deviceId: String?
    let message: String
    let createdAt: Int
    let updatedAt: String?
    let id: String // For `_id` field in MongoDB

    enum CodingKeys: String, CodingKey {
        case userId
        case deviceId
        case message
        case createdAt
        case updatedAt
        case id = "_id"
    }
}
