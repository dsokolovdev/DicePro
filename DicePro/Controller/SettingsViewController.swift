//
//  SettingsTableViewController.swift
//  DicePro
//
//  Created by Dmitri  on 02.12.25.
//

// SettingsViewController.swift

import UIKit

final class SettingsViewController: UITableViewController {
    
    // Текущие настройки (копия, с которой работает экран)
    var settings: Settings
    var resetButton: UIButton!
    
    /// Колбэк, через который отдаем новые настройки обратно в DiceViewController
    var onSettingsChanged: ((Settings) -> Void)?
    
    // Твои секции
    enum Section: Int, CaseIterable {
        case players     // Player 3, Player 4
        case options     // Two dices, Screen always on
        case reset       // Reset
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
        configureFooter()
        tableView.bounces = false
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.cellLayoutMarginsFollowReadableWidth = true
        }
    }
    
    // При уходе с экрана — сообщаем наверх новые настройки
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsChanged?(settings)
    }
}

extension SettingsViewController {
    
    //MARK:  -  DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        
        switch sec {
        case .players:
            return 2    // Player 3, Player 4
        case .options:
            return 2    // Two dices, Screen always on
        case .reset:
            return 1    // Reset
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        let size: CGFloat = 16 * scaleFactor
        
        switch section {
        // MARK: - SECTION 0: Players
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
            
        // MARK: - SECTION 1: Options
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
            
        // MARK: - SECTION 2: Reset
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
    
    func updateResetButtonState() {
        //UIView.transition(with: resetButton, duration: 0.15, options: .transitionCrossDissolve) { [self] in
            resetButton.isEnabled = !settings.isDefault
        //}
    }
}

//MARK: - Actions
extension SettingsViewController {
    
    @objc private func playerSwitchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 3:
            settings.isPlayer3Enabled = sender.isOn
        case 4:
            settings.isPlayer4Enabled = sender.isOn
        default:
            break
        }
        updateResetButtonState()
    }
    
    @objc private func optionSwitchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 10:
            settings.isTwoDicesEnabled = sender.isOn
        case 11:
            settings.isScreenAlwaysOnEnabled = sender.isOn
        default:
            break
        }
        updateResetButtonState()
    }
    
    @objc private func resetPressed() {
        settings = .defaults

        // Анимация переключателей
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

        // Передаём настройки наверх
        onSettingsChanged?(settings)
    }
}

extension SettingsViewController {
    /// Configures and attaches a custom footer view at the bottom of the table.
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
            
            let wConstant: CGFloat = 16 * scaleFactor
            let hConstant: CGFloat = 8 * scaleFactor
            NSLayoutConstraint.activate([
                footerLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: wConstant),
                footerLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -wConstant),
                footerLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: hConstant),
                footerLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -hConstant)
            ])
            let height: CGFloat = 120 * scaleFactor
            footerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
            tableView.tableFooterView = footerView
        }
}
