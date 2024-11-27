//
//  GetIPAddress.swift
//  DeviceDetector
//
//  Created by Bobby on 11/22/24.
//
import Foundation

func getIPAddress() -> String? {
    var address: String?
    
    // Get list of all interfaces on the device
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        
        // Iterate through interfaces
        while ptr != nil {
            let interface = ptr!.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            // Check for IPv4 (AF_INET) interface
            if addrFamily == UInt8(AF_INET) {
                // Convert interface address to a human-readable string in dot notation
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if (getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                    let ip = String(cString: hostname)
                    
                    // Check for valid interface name (e.g., en0 for Wi-Fi)
                    if let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
                        address = ip
                        break // Exit loop when we find the first valid IP
                    }
                }
            }
            ptr = ptr!.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    return address
}
