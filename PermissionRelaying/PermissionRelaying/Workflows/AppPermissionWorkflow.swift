//
//  AppPermissionWorkflow.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import Combine

// App 全体の 起動時の PermissionWorkFlow
class AppPermissionWorkFlow: PermissionWorkFlow {

    typealias Output = ()
    typealias Failure = Never

    private var cancellable = Set<AnyCancellable>()

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {

        // SDK ごとに定義する
        let sdk1Workflow = SetupTangerineWorkFlow()
            .flatMap { status -> AnyPublisher<(), Never> in
                return Just(()).eraseToAnyPublisher()
            }
        let sdk2Workflow = SetupTangerineWorkFlow()
            .flatMap { status -> AnyPublisher<(), Never> in
                return Just(()).eraseToAnyPublisher()
            }
        Publishers.Merge(sdk1Workflow, sdk2Workflow)
            .sink { _ in
                _ = subscriber.receive(())
                subscriber.receive(completion: .finished)
            }
            .store(in: &cancellable)

    }
}
