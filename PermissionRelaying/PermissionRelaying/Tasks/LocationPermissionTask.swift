//
//  LocationPermissionTask.swift
//  PermissionRelaying
//
//  Created by naoyuki.kan on 2022/12/27.
//

import Foundation
import CoreLocation

@MainActor
class LocationPermissionTask: NSObject, PermissionTask {
    fileprivate var locationManager: CLLocationManager?
    fileprivate var continuation: AuthorizationStatusContinuation?

    typealias AuthorizationStatusContinuation = CheckedContinuation<CLAuthorizationStatus, Never>

    func request() async -> PermissionAuthorizationStatus {
        let authorizationStatus: CLAuthorizationStatus
        if locationManager == nil {
            locationManager = CLLocationManager()
        }

        if locationManager?.authorizationStatus == .notDetermined {
            locationManager?.delegate = self
            authorizationStatus = await withCheckedContinuation { [weak self] (continuation: AuthorizationStatusContinuation) in
                guard let self = self else { return }
                self.continuation = continuation
                self.locationManager?.requestAlwaysAuthorization()
            }
        } else {
            guard let status = locationManager?.authorizationStatus else { fatalError() }
            authorizationStatus = status
        }
        return .location(authorizationStatus)
    }

    func checkStatus() async -> PermissionAuthorizationStatus {
        guard let locationManager = locationManager else {
            locationManager = CLLocationManager()
            return .location(locationManager!.authorizationStatus)
        }
        return .location(locationManager.authorizationStatus)
    }
}

extension LocationPermissionTask: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .notDetermined { return }
        continuation?.resume(returning: manager.authorizationStatus)
    }
}
