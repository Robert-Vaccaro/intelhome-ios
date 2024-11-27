//
//  KeychainHelper.swift
//  DeviceDetector
//
//  Created by Bobby on 11/26/24.
//

import Foundation
import Security

struct KeychainHelper {
    private static let service = "com.robertvaccaro.Sweep.DeviceDetector"
    static let account = SessionData.refreshToken // Identifier for the token entry
    
    // Store refresh token in Keychain
    static func storeRefreshToken(_ token: String) -> Bool {
        // Convert token to Data
        guard let tokenData = token.data(using: .utf8) else {
            return false
        }
        
        // Check if the item already exists
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        SecItemDelete(query) // Ensure no duplicates
        
        // Add the new token
        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: tokenData
        ] as CFDictionary
        
        let status = SecItemAdd(attributes, nil)
        return status == errSecSuccess
    }
    
    // Retrieve refresh token from Keychain
    static func retrieveRefreshToken() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        
        guard status == errSecSuccess, let tokenData = item as? Data else {
            return nil
        }
        
        return String(data: tokenData, encoding: .utf8)
    }
    
    // Delete refresh token from Keychain
    static func deleteRefreshToken() -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        return status == errSecSuccess
    }
}
