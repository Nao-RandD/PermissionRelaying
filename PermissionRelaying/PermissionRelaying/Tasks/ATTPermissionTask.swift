//
//  ATTPermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import AppTrackingTransparency

struct ATTPermissionTask: PermissionTask {
    func request() async -> PermissionAuthorizationStatus {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        return .att(status)
    }
}
