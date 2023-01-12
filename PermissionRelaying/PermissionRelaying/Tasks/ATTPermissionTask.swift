//
//  ATTPermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import AppTrackingTransparency

struct ATTPermissionTask: PermissionTask {
    func checkStatus() async -> PermissionAuthorizationStatus {
        return .att(ATTrackingManager.trackingAuthorizationStatus)
    }

    func request() async -> PermissionAuthorizationStatus {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        return .att(status)
    }
}
