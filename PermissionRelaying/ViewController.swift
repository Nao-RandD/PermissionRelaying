//
//  ViewController.swift
//  PermissionRelaying
//
//  Created by Atsushi Miyake on 2022/12/02.
//

import UIKit
import Combine
import AppTrackingTransparency

class ViewController: UIViewController {

    private var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 連続する権限をWorkflowとして順番に要求する()
        割り込みの権限要求はキューイングして前の権限要求が完了したら実行する()
        // workflowの割り込み()
    }

    // 依存関係のある直列した権限要求
    func 連続する権限をWorkflowとして順番に要求する() {
        Task {
            await PermissionManager.shared.queuing(task: SetupTangerineWorkflow())
        }
    }

    // 依存関係がない並列する権限要求
    func 割り込みの権限要求はキューイングして前の権限要求が完了したら実行する() {
        // Task を実行しておく
        Task {
            await PermissionManager.shared.queuing(task: ATTPermissionTask())
        }
        // 1秒待って割り込みさせる
        Task {
            try await Task.sleep(nanoseconds: 1000000000)
            await PermissionManager.shared.queuing(task: NotificationPermissionTask())
        }
    }

    // 依存関係がない並列する権限要求 (Task と Workflow)
    func workflowの割り込み() {
        // Workflow を実行しておく
        Task {
            await PermissionManager.shared.queuing(task: SetupTangerineWorkflow())
        }
        // 1秒待って割り込みさせる
        Task {
            await PermissionManager.shared.queuing(task: NotificationPermissionTask())
        }
    }
}

