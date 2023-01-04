//
//  TangerinePermissionWorkflow.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import AppTrackingTransparency

struct SetupTangerineWorkflow: PermissionTask {
    func request() async -> PermissionAuthorizationStatus {
        let attStatus = await ATTPermissionTask().request()
        guard case .att(let status) = attStatus,
              status == .authorized else {
            return attStatus
        }
        let locationStatus = await LocationPermissionTask().request()
        guard case .location(let status) = locationStatus,
              status == .authorizedAlways || status == .authorizedWhenInUse else {
            return locationStatus
        }
        return await NotificationPermissionTask().request()
    }
}
