//
//  NotificationPermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import UserNotifications

struct NotificationPermissionTask: PermissionTask {
    func checkStatus() async -> PermissionAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .ephemeral, .provisional, .notDetermined, .denied:
                    continuation.resume(with: .success(.notification(settings.authorizationStatus)))
                @unknown default:
                    preconditionFailure()
                }
            }
        }
    }

    func request() async -> PermissionAuthorizationStatus {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert])
            if granted {
                return await withCheckedContinuation { continuation in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        switch settings.authorizationStatus {
                        case .authorized, .ephemeral, .provisional, .notDetermined, .denied:
                            continuation.resume(with: .success(.notification(settings.authorizationStatus)))
                        @unknown default:
                            preconditionFailure()
                        }
                    }
                }
            } else {
                return .failure
            }
        } catch {
            return .failure
        }
    }
}
