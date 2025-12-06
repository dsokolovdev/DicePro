//
//  SettingsViewController.swift
//  DicePro
//
//  Created by Dmitri on 02.12.25.
//

import UIKit

/// Displays and edits user settings such as player options,
/// dice options and persistent system behavior.
final class SettingsViewController: UITableViewController {
    
    // MARK: - Stored Properties
    
    /// A working copy of the current settings.
    var settings: Settings
    
    /// Button used in the Reset section.
    var resetButton: UIButton!
    
    /// Callback that passes updated settings back to DiceViewController.
    var onSettingsChanged: ((Settings) -> Void)?
    
    /// Table sections used on the screen.
    enum Section: Int, CaseIterable {
        case players     // Player 3, Player 4
        case options     // Two dices, Screen always on
        case reset       // Reset button
    }
    
    // MARK: - Init
    
    init(settings: Settings) {
        self.settings = settings
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        tableView.rowHeight = 44 * scaleFactor
        tableView.bounces = false
        
        configureFooter()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.cellLayoutMarginsFollowReadableWidth = true
        }
    }
    
    /// Sends updated settings back to the parent controller.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsChanged?(settings)
    }
}

// MARK: - UITableView Data Source

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        
        switch sec {
        case .players: return 2
        case .options: return 2
        case .reset:   return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        let size: CGFloat = 17 * scaleFactor
        
        switch section {
            
            // MARK: Section 0 — Players
        case .players:
            let toggle = UISwitch()
            toggle.addTarget(self, action: #selector(playerSwitchChanged(_:)), for: .valueChanged)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Player 3"
                toggle.isOn = settings.isPlayer3Enabled
                toggle.tag = 3
            } else {
                cell.textLabel?.text = "Player 4"
                toggle.isOn = settings.isPlayer4Enabled
                toggle.tag = 4
            }
            cell.accessoryView = toggle
            
            // MARK: Section 1 — Game Options
        case .options:
            let toggle = UISwitch()
            toggle.addTarget(self, action: #selector(optionSwitchChanged(_:)), for: .valueChanged)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Two dices"
                toggle.isOn = settings.isTwoDicesEnabled
                toggle.tag = 10
            } else {
                cell.textLabel?.text = "Screen always on"
                toggle.isOn = settings.isScreenAlwaysOnEnabled
                toggle.tag = 11
            }
            cell.accessoryView = toggle
            
            // MARK: Section 2 — Reset Button
        case .reset:
            cell.textLabel?.text = "Reset Settings"
            cell.textLabel?.textColor = .label
            
            resetButton = UIButton(type: .system)
            resetButton.setTitle("Reset", for: .normal)
            resetButton.titleLabel?.font = .systemFont(ofSize: size, weight: .medium)
            resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
            resetButton.isEnabled = !settings.isDefault
            resetButton.sizeToFit()
            cell.accessoryView = resetButton
        }
        cell.textLabel?.font = .systemFont(ofSize: size)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        
        switch sec {
        case .players: return "Players"
        case .options: return "Game Options"
        case .reset:   return nil
        }
    }
    
    /// Enables or disables the Reset button depending on the current settings state.
    func updateResetButtonState() {
        resetButton.isEnabled = !settings.isDefault
    }
}

// MARK: - Actions

extension SettingsViewController {
    
    @objc private func playerSwitchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 3: settings.isPlayer3Enabled = sender.isOn
        case 4: settings.isPlayer4Enabled = sender.isOn
        default: break
        }
        updateResetButtonState()
    }
    
    @objc private func optionSwitchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 10: settings.isTwoDicesEnabled = sender.isOn
        case 11: settings.isScreenAlwaysOnEnabled = sender.isOn
        default: break
        }
        updateResetButtonState()
    }
    
    @objc private func resetPressed() {
        settings = .defaults
        
        // Smoothly reset visible toggles
        for cell in tableView.visibleCells {
            guard let toggle = cell.accessoryView as? UISwitch else { continue }
            
            switch cell.textLabel?.text {
            case "Player 3": toggle.setOn(false, animated: true)
            case "Player 4": toggle.setOn(false, animated: true)
            case "Two dices": toggle.setOn(false, animated: true)
            case "Screen always on": toggle.setOn(false, animated: true)
            default: break
            }
        }
        
        updateResetButtonState()
        onSettingsChanged?(settings)
    }
}

// MARK: - Footer Configuration

extension SettingsViewController {
    
    /// Attaches footer text displaying version/build information.
    private func configureFooter() {
        let size: CGFloat = max(12, 13 * scaleFactor)
        
        let footerLabel = UILabel()
        footerLabel.text = Settings.settingsFooterText
        footerLabel.font = .systemFont(ofSize: size)
        footerLabel.textColor = .secondaryLabel
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let footerView = UIView()
        footerView.addSubview(footerLabel)
        
        let w: CGFloat = 16 * scaleFactor
        let h: CGFloat = 8 * scaleFactor
        
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: w),
            footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -w),
            footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: h),
            footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -h)
        ])
        
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 120 * scaleFactor)
        tableView.tableFooterView = footerView
    }
}
