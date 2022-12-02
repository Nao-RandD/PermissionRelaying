//
//  NotificationPermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import UserNotifications
import Combine

struct NotificationPermissionTask: PermissionTask {

    typealias Output = UNAuthorizationStatus
    typealias Failure = Never

    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = PermissionSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    struct PermissionSubscription<S: Subscriber>: Subscription
    where S.Input == NotificationPermissionTask.Output, S.Failure == NotificationPermissionTask.Failure {

        let combineIdentifier = CombineIdentifier()
        let subscriber: S

        init(subscriber: S) {
            self.subscriber = subscriber
            request()
        }

        func request(_ demand: Subscribers.Demand) {}
        func cancel() {}
    }
}

extension NotificationPermissionTask.PermissionSubscription {
    func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            if error == nil && granted {
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                    _ = subscriber.receive(settings.authorizationStatus)
                    subscriber.receive(completion: .finished)
                })
            } else {
                subscriber.receive(completion: .finished)
            }
        })
    }
}
