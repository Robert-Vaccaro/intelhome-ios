//
//  UserTokens.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//

import Foundation

struct UserTokens: Decodable {
    let message: String?
    let error: String?
    let user: User?
    let tokens: Tokens?
}
