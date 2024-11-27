//
//  User.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//

import Foundation

struct User: Decodable {
    let userId: String
    let phone: String
    let email: String
    let role: [String]
    let firstName: String
    let lastName: String
    let profilePhoto: String
    let banned: Bool
    let phoneVerification: Bool
    let phoneCode: String
    let phoneCodeExp: Int
    let emailVerification: Bool
    let emailCode: String
    let emailCodeExp: Int
    var locations: [String]?
    var emailNotifications: Bool
    var textNotifications: Bool
    var pushNotifications: Bool
    let DTString: String
    let createdAt: String
    let updatedAt: String
}
