//
//  TangerinePermissionWorkflow.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import Combine
import AppTrackingTransparency
import UserNotifications

class SetupTangerineWorkFlow: PermissionWorkFlow {

    enum AuthorizationStatus {
        case authorized
        case unauthorizedNotification(status: UNAuthorizationStatus)
        case unauthorizedAtt(status: ATTrackingManager.AuthorizationStatus)
    }

    enum UnauthorizedError: Error {
        case att(ATTrackingManager.AuthorizationStatus)
        case notification(UNAuthorizationStatus)
    }

    typealias Output = AuthorizationStatus
    typealias Failure = Never

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = WorkflowSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    class WorkflowSubscription<S: Subscriber>: Subscription where S.Input == SetupTangerineWorkFlow.Output {

        let combineIdentifier = CombineIdentifier()
        let subscriber: S
        private var cancellable = Set<AnyCancellable>()

        init(subscriber: S) {
            self.subscriber = subscriber
            executeTasks()
        }

        func request(_ demand: Subscribers.Demand) {}
        func cancel() {}
    }
}

extension SetupTangerineWorkFlow.WorkflowSubscription {
    func executeTasks() {
        // 実際には
        // 1. 位置情報
        // 2. ATT
        // 3. Bluetooth
        // だけど仮実装が面倒なので ATT → Notification で検証
        ATTPermissionTask()
            // ATT Permission
            .flatMap { [weak self] status -> AnyPublisher<NotificationPermissionTask.Output, Never> in
                switch status {
                case .authorized:
                    return NotificationPermissionTask().eraseToAnyPublisher()
                case .notDetermined, .restricted, .denied:
                    _ = self?.subscriber.receive(.unauthorizedAtt(status: status))
                    return Empty().eraseToAnyPublisher()
                @unknown default:
                    preconditionFailure()
                }
            }
            // Notification Permission
            .sink { [weak self] status in
                switch status {
                case .authorized, .provisional, .ephemeral: // 適当
                    _ = self?.subscriber.receive(.authorized)
                case .notDetermined, .denied:
                    _ = self?.subscriber.receive(.unauthorizedNotification(status: status))
                @unknown default:
                    preconditionFailure()
                }
                // 全ての権限要求のリレーが完了したら SDK を初期化する
                // Tangerine の場合は SDK 初期化時に Bluetooth の権限を要求するので
                // BluetoothPermissionTask を定義して任意のタイミングで権限要求できるようにすると扱いやすいかも
                self?.subscriber.receive(completion: .finished)
            }
            .store(in: &cancellable)



    }
}
