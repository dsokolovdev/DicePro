//
//  SettingsTableViewController.swift
//  DicePro
//
//  Created by Dmitri  on 02.12.25.
//

import UIKit

final class SettingsViewController: UITableViewController {
    
    var settings: Settings
    var onSettingsChanged: ((Settings) -> Void)?
    
    init(settings: Settings) {
        self.settings = settings
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}
