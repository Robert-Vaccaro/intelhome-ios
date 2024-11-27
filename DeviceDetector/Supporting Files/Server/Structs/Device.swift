//
//  Device.swift
//  DeviceDetector
//
//  Created by Bobby on 11/23/24.
//

import Foundation

struct Device: Decodable {
    let userId: String
    let name: String
    let type: String
    var location: String
    let capabilities: [String]
    let specifications: String
    let detectedAt: Int
    let needsUpdate: Bool
}

struct Devices: Decodable {
    let id: String
    let name: String
    let type: String
    let detectedAt: Int
    let needsUpdate: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case type
        case detectedAt
        case needsUpdate
    }
}


struct CreatedDeviceResponse: Decodable {
    let message: String
    let device: Device
}
