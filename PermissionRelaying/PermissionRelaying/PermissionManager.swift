//
//  Manager.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import Foundation

final class PermissionManager {

    static let shared = PermissionManager()

    enum OperationStatus {
        case running
        case waiting
    }

    private var queue: [PermissionTask] = []
    private var operationStatus: OperationStatus = .waiting

    private init() {}

    // MARK: - Internal methods

    func queuing(task: PermissionTask) async {
        queue.append(task)
        if operationStatus == .waiting {
            await executeTask()
        }
    }

    func queuing(workflow: PermissionWorkflow) async {
        await queuing(task: workflow)
    }

    // MARK: - Private methods

    private func executeTask() async {
        guard let queuedTask = queue.first else {
            operationStatus = .waiting
            return
        }
        operationStatus = .running
        let _ = await queuedTask.request()
        queue.removeFirst()
        await executeTask()
    }
}
