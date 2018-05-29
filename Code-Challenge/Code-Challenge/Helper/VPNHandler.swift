//
//  VPNManager.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 27/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import Foundation
import NetworkExtension
import Security

// Identifiers
fileprivate let password = "xpcnwg6abh"
fileprivate let userName = "prd_test_j4d3vk6"

class VPNHandler {
  let vpnManager = NEVPNManager.shared()
  static let shared = VPNHandler()
  var completion: ((Result<String>) -> ())?
 
  func configureProtocol(serverName: String, remoteID: String, completion: @escaping (Result<String>) -> ()) {
  
    self.completion = completion
    vpnManager.loadFromPreferences {[unowned self] error in
      if let error = error {
        self.completion?(.failure(error.localizedDescription))
      } else {
        
        let configuration:NEVPNProtocolIKEv2
        
        if self.vpnManager.protocolConfiguration != nil {
          configuration = self.vpnManager.protocolConfiguration as! NEVPNProtocolIKEv2
        } else {
          configuration = NEVPNProtocolIKEv2()
          configuration.username = userName
          configuration.passwordReference = self.savePassword(password, inKeychainItem: nil)
          configuration.authenticationMethod = .none
          configuration.useExtendedAuthentication = true
          configuration.disconnectOnSleep = false
        }
        configuration.serverAddress = serverName
        configuration.remoteIdentifier = remoteID
        configuration.localIdentifier = remoteID
        self.vpnManager.protocolConfiguration = configuration
        self.vpnManager.localizedDescription = "sid's VPN"
        self.vpnManager.isEnabled = true
        
        self.vpnManager.saveToPreferences {[unowned self] error in
          if let error = error {
            self.completion?(.failure(error.localizedDescription))
          } else {
            self.vpnManager.loadFromPreferences {[unowned self] error in
              if let error = error {
                self.completion?(.failure(error.localizedDescription))
              } else {
                  self.connect(completion: completion)
              }
            }
          }
        }
      }
    }
  }
  
  func connect(completion: @escaping (Result<String>) -> ()) {
    
    func connect() {
      do {
        try vpnManager.connection.startVPNTunnel()
      } catch let error {
        completion(.failure(error.localizedDescription))
      }
    }
    
    switch vpnManager.connection.status {
    case .invalid, .connected, .connecting, .reasserting, .disconnecting:
      disconnect()
      connect()
    case .disconnected:
      connect()
    }
  }
  
  func checkConnection() {
    vpnManager.loadFromPreferences { (error) in
      if error != nil {
        print(error.debugDescription)
      }
      else{
        print("No error from loading VPN viewDidLoad")
      }
    }

  }
  func connect() {
    do {
      try vpnManager.connection.startVPNTunnel()
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func disconnect() {
    vpnManager.connection.stopVPNTunnel()
  }
  
  /// Save a password in the keychain.
  func savePassword(_ password: String, inKeychainItem: Data?) -> Data? {
    guard let passwordData = password.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return nil }
    var status = errSecSuccess
    
    if let persistentReference = inKeychainItem {
      // A persistent reference was given, update the corresponding keychain item.
      let query: [NSObject: AnyObject] = [
        kSecValuePersistentRef : persistentReference as AnyObject,
        kSecReturnAttributes : kCFBooleanTrue
      ]
      var result: AnyObject?
      
      // Get the current attributes for the item.
      status = SecItemCopyMatching(query as CFDictionary, &result)
      
      if let attributes = result as? [NSObject: AnyObject] , status == errSecSuccess {
        // Update the attributes with the new data.
        var updateQuery = [NSObject: AnyObject]()
        updateQuery[kSecClass] = kSecClassGenericPassword
        updateQuery[kSecAttrService] = attributes[kSecAttrService]
        
        var newAttributes = attributes
        newAttributes[kSecValueData] = passwordData as AnyObject?
        
        status = SecItemUpdate(updateQuery as CFDictionary, newAttributes as CFDictionary)
        if status == errSecSuccess {
          return persistentReference
        }
      }
    }
    
    if inKeychainItem == nil || status != errSecSuccess {
      // No persistent reference was provided, or the update failed. Add a new keychain item.
      
      let attributes: [NSObject: AnyObject] = [
        kSecAttrService : UUID().uuidString as AnyObject,
        kSecValueData : passwordData as AnyObject,
        kSecAttrAccessible : kSecAttrAccessibleAlways,
        kSecClass : kSecClassGenericPassword,
        kSecReturnPersistentRef : kCFBooleanTrue
      ]
      
      var result: AnyObject?
      status = SecItemAdd(attributes as CFDictionary, &result)
      
      if let newPersistentReference = result as? Data , status == errSecSuccess {
        return newPersistentReference
      }
    }
    return nil
  }
  
  
  
  /// Get a password from the keychain.
  func getPasswordWithPersistentReference(_ persistentReference: Data) -> String? {
    var result: String?
    let query: [NSObject: AnyObject] = [
      kSecClass : kSecClassGenericPassword,
      kSecReturnData : kCFBooleanTrue,
      kSecValuePersistentRef : persistentReference as AnyObject
    ]
    
    var returnValue: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &returnValue)
    
    if let passwordData = returnValue as? Data , status == errSecSuccess {
      result = NSString(data: passwordData, encoding: String.Encoding.utf8.rawValue) as? String
    }
    return result
  }

}
