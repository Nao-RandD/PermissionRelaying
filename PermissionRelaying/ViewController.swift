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
        // 割り込みの権限要求はキューイングして前の権限要求が完了したら実行する()
        // workflowの割り込み()
    }

    // 依存関係のある直列した権限要求
    func 連続する権限をWorkflowとして順番に要求する() {
        Manager.shared.queuing(workflow: SetupTangerineWorkFlow())
    }

    // 依存関係がない並列する権限要求
    func 割り込みの権限要求はキューイングして前の権限要求が完了したら実行する() {
        // Task を実行しておく
        Manager.shared.queuing(task: ATTPermissionTask())
        // 1秒待って割り込みさせる
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            Manager.shared.queuing(task: NotificationPermissionTask())
        })
    }

    // 依存関係がない並列する権限要求 (Task と Workflow)
    func workflowの割り込み() {
        // Workflow を実行しておく
        Manager.shared.queuing(workflow: SetupTangerineWorkFlow())
        // 1秒待って Task を割り込みさせる
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            Manager.shared.queuing(task: NotificationPermissionTask())
        })
    }
}

