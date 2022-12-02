//
//  Manager.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation
import Combine

final class Manager {

    static let shared = Manager()

    enum OperationStatus {
        case running
        case waiting
    }

    typealias Task = AnyPublisher<(), Never>
    typealias Workflow = AnyPublisher<(), Never>
    typealias Queue = [Task]
    typealias TaskOpearatorValue = (queue: Queue, operationStatus: OperationStatus)
    typealias TaskOpearator = CurrentValueSubject<TaskOpearatorValue, Never>

    private var taskOperator = TaskOpearator((queue: [], operationStatus: .waiting))
    private var cancellable = Set<AnyCancellable>()

    init() {
        // queuing された順番で TaskOperator が waiting の場合に task を実行する
        taskOperator
            .filter { queue, operationStatus in
                !queue.isEmpty && operationStatus == .waiting
            }
            .handleEvents(receiveOutput: { [weak self] queue, operationStatus in
                guard let self = self else { return }
                self.taskOperator.send((queue, .running))
            })
            .flatMap { queue, _ -> Task in
                if let task = queue.first {
                    return task
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }
            .sink { [weak self] _ in
                guard let self = self else { return }
                let value = self.taskOperator.value
                if value.queue.isEmpty {
                    self.taskOperator.send(([], .waiting))
                } else {
                    var _queue = value.queue
                    _queue.removeFirst()
                    self.taskOperator.send((_queue, .waiting))
                }
            }
            .store(in: &cancellable)
    }

    func queuing(task: Task) {
        let value = taskOperator.value
        var queue = value.queue
        queue.append(task)
        taskOperator.send((queue, value.operationStatus))
    }

    func queuing(workflow: Workflow) {
        queuing(task: workflow)
    }

    func queuing<P, Output>(task: P) where P: PermissionTask, P.Output == Output, P.Failure == Never {
        let _task = task.map { _ in return () }.eraseToAnyPublisher()
        let value = taskOperator.value
        var queue = value.queue
        queue.append(_task)
        taskOperator.send((queue, value.operationStatus))
    }

    func queuing<P, Output>(workflow: P) where P: PermissionWorkFlow, P.Output == Output, P.Failure == Never {
        let _task = workflow.map { _ in return () }.eraseToAnyPublisher()
        queuing(workflow: _task)
    }
}
