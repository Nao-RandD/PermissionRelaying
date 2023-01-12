//
//  PermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import Combine
import AppTrackingTransparency
import UserNotifications
import CoreLocation

indirect enum PermissionAuthorizationStatus {
    case att(ATTrackingManager.AuthorizationStatus)
    case notification(UNAuthorizationStatus)
    case location(CLAuthorizationStatus)
    case tangerine(PermissionAuthorizationStatus,
                   PermissionAuthorizationStatus,
                   PermissionAuthorizationStatus)
    case failure
}

protocol PermissionTask {
    func checkStatus() async -> PermissionAuthorizationStatus
    func request() async -> PermissionAuthorizationStatus
}
