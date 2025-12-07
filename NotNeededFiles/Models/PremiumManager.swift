//
//  PremiumManager.swift
//  EarnLog
//
//  Created by M3 pro on 17/08/2025.
//

import Foundation

final class PremiumManager{
    static let shared = PremiumManager()
    
    private let premiumKey = "isPremium"
    
    private init(){}
    
    var isPremium: Bool {
        UserDefaults.standard.bool(forKey: premiumKey)
    }
    
    func activatePremium(){
        UserDefaults.standard.set(true, forKey: premiumKey)
    }
    
    func deactivatePremium(){
        UserDefaults.standard.set(false, forKey: premiumKey)
    }
}
