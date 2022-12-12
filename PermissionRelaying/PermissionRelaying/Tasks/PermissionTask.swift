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

enum PermissionAuthorizationStatus {
    case att(ATTrackingManager.AuthorizationStatus)
    case notification(UNAuthorizationStatus)
    case failure
}

protocol PermissionTask {
    func request() async -> PermissionAuthorizationStatus
}
