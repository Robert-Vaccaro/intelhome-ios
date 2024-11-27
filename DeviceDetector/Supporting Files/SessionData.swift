//
//  AppData.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import Foundation

struct SessionData {
//    Automatically get ip address for testing locally on a simulator
//    static var serverUrl: String {
//        if let ipAddress = getIPAddress() {
//            print("IP Address: \(ipAddress)")
//            return "http://\(ipAddress):3001"
//        } else {
//            print("Unable to determine IP address")
//            return ""
//        }
//    }

//    For testing locally on a physical device (manually add ip address)
//    static var serverUrl: String = "http://...:3001"

    // Deployed server
    static var serverUrl: String = "https://intel-home-backend-bc77c6576710.herokuapp.com"
    static var accessToken = ""
    static var refreshToken = ""
    static var DTString = ""
    static var currectLocation = ""
    static var user:User!
    static var deviceCount:Int = 0
    static var notifications:[AppNotification]!
    static var tabBarVC: MainTabBarController!
}
