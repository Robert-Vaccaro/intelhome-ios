//
//  Locations.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//

import Foundation

struct LocationResponse: Codable {
    let locations: [String]?
    let message: String?
    let error: String?
}
