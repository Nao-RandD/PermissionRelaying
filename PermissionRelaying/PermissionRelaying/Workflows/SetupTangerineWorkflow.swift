//
//  TangerinePermissionWorkflow.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import AppTrackingTransparency

struct SetupTangerineWorkflow: PermissionTask {
    func checkStatus() async -> PermissionAuthorizationStatus {
        let attStatus = await ATTPermissionTask().checkStatus()
        guard case .att(_) = attStatus else {
            preconditionFailure()
        }
        let locationStatus = await LocationPermissionTask().checkStatus()
        guard case .location(_) = locationStatus else {
            preconditionFailure()
        }
        let notificationStatus = await NotificationPermissionTask().checkStatus()
        guard case .notification(_) = notificationStatus else {
            preconditionFailure()
        }
        return .tangerine(attStatus, notificationStatus, locationStatus)
    }

    func request() async -> PermissionAuthorizationStatus {
        let attStatus = await ATTPermissionTask().request()
        guard case .att(_) = attStatus else {
            preconditionFailure()
        }
        let locationStatus = await LocationPermissionTask().request()
        guard case .location(_) = locationStatus else {
            preconditionFailure()
        }
        let notificationStatus = await NotificationPermissionTask().request()
        guard case .notification(_) = notificationStatus else {
            preconditionFailure()
        }
        return .tangerine(attStatus, notificationStatus, locationStatus)
    }
}
