//
//  ATTPermissionTask.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import AppTrackingTransparency
import Combine

class ATTPermissionTask: PermissionTask {

    typealias Output = ATTrackingManager.AuthorizationStatus
    typealias Failure = Never

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = PermissionSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    struct PermissionSubscription<S: Subscriber>: Subscription where S.Input == ATTPermissionTask.Output {

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

extension ATTPermissionTask.PermissionSubscription {
    private func request() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                _ = subscriber.receive(status)
                subscriber.receive(completion: .finished)
            }
        })
    }
}
