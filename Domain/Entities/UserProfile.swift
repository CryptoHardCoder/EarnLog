//
//  UserProfile.swift
//  EarnLog
//
//  Created by M3 pro on 06/11/2025.
//
import Foundation

struct UserProfile {
    var id: String
    var name: String
    var email: String
    var avatarURL: String?
    var goal: Double?
    var currency: String?
    var language: String

    var createdAt: Date
    var lastLoginAt: Date?

    var sideJobs: [SideJob]?
    var settings: UserSettings
    var plan: SubscriptionPlan
}
