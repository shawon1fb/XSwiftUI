//
//  ApiKeyInterceptor.swift
//  XSwiftUI
//
//  Created by Shahanul Haque on 4/19/25.
//
import EasyXConnect
import Foundation
import Security

@available(iOS 15.0, macOS 12.0, *)
public final class ApiKeyManager {
    
    private static let keychainService = "com.apimanager.keys"
    private static let keysListKey = "api_keys_list"
    private static let queue = DispatchQueue(label: "com.apimanager.queue")
    
    // Helper methods for Keychain access
    private static func saveToKeychain(key: String, value: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        // First, delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Then add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private static func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        return nil
    }
    
    private static func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // Store list of keys in Keychain
    private static func saveKeysList(keys: [String]) {
        if let keysData = try? JSONSerialization.data(withJSONObject: keys) {
            if let keysString = String(data: keysData, encoding: .utf8) {
                _ = saveToKeychain(key: keysListKey, value: keysString)
            }
        }
    }
    
    // Get list of keys from Keychain
    private static func getKeysList() -> [String] {
        if let keysString = loadFromKeychain(key: keysListKey),
           let keysData = keysString.data(using: .utf8),
           let keys = try? JSONSerialization.jsonObject(with: keysData) as? [String] {
            return keys
        }
        return []
    }
    
    // Public methods
    
    // Add a new secret key-value pair
    public static func addSecret(key: String, value: String) {
        queue.sync {
            _ = saveToKeychain(key: key, value: value)
            
            // Update the list of keys
            var keysList = getKeysList()
            if !keysList.contains(key) {
                keysList.append(key)
                saveKeysList(keys: keysList)
            }
        }
    }
    
    // Get a secret value by key
    public static func getSecret(key: String) -> String? {
        return queue.sync {
            return loadFromKeychain(key: key)
        }
    }
    
    // Delete a secret by key
    public static func deleteSecret(key: String) {
        queue.sync {
            _ = deleteFromKeychain(key: key)
            
            // Update the list of keys
            var keysList = getKeysList()
            if let index = keysList.firstIndex(of: key) {
                keysList.remove(at: index)
                saveKeysList(keys: keysList)
            }
        }
    }
    
    // Get all stored keys
    public static func getAllKeys() -> [String] {
        return queue.sync {
            return getKeysList()
        }
    }
    
    // Get all key-value pairs as a dictionary
    public static func getAllKeyValues() -> [String: String] {
        return queue.sync {
            var keyValues = [String: String]()
            
            let keys = getKeysList()
            for key in keys {
                if let value = loadFromKeychain(key: key) {
                    keyValues[key] = value
                }
            }
            
            return keyValues
        }
    }
    
    // Clear all stored API keys
    public static func clearAllSecrets() {
        queue.sync {
            let keys = getKeysList()
            for key in keys {
                _ = deleteFromKeychain(key: key)
            }
            _ = deleteFromKeychain(key: keysListKey)
        }
    }
    
    // Export all keys as a JSON string
    public static func exportKeysAsJSON() -> String? {
        let keyValues = getAllKeyValues()
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: keyValues) {
            return String(data: jsonData, encoding: .utf8)
        }
        
        return nil
    }
}

// Updated interceptor to use the ApiKeyManager
final class ApiKeyInterceptor: Intercepter {
    func onRequest(req: URLRequest) async throws -> (URLRequest, Data?) {
        var mutableReq = req
        
        // Get all API keys and add them as headers
        let headers = ApiKeyManager.getAllKeyValues()
        
        for (key, value) in headers {
            mutableReq.setValue(value, forHTTPHeaderField: key)
        }
        
        return (mutableReq, nil)
    }
    
    func onResponse(req: URLRequest, res: URLResponse?, data: Data, modifiedData: Data?, customResponse: URLResponse?) async throws -> (Data, URLResponse?) {
        return (data, customResponse)
    }
}
