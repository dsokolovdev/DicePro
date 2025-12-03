//
//  ViewController.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//

import UIKit

class DiceViewController: UIViewController {
    private var model: DiceModel
    var settings = Settings.defaults
    private var scoresView: ScoresView!
    private var lightHaptic: UIImpactFeedbackGenerator!
    private var currentLayout: LayoutType = .row {
        didSet {
            guard scoresView != nil else { return }
            scoresView.update(players: model.data.players, layout: currentLayout)
            scoresView.updateLablesColors(activePlayer: playerSegmentedControl.selectedSegmentIndex)
        }
    }
    private var viewButton: UIBarButtonItem!
    private var settingsButton: UIBarButtonItem!
    private var resetScoreButton: UIBarButtonItem!
    private var playerSegmentedControl: UISegmentedControl!
    private var playerSegmentedControlBarView: UIView!
    private let dice1 = UIImageView()
    private let dice2 = UIImageView()
    private let dice1Color = DiceModel.Dices.WhiteBlue
    private let dice2Color = DiceModel.Dices.BlueGrey
    private var rollButton: UIButton!
    private var rollBar: UIToolbar!
    private var diceStack: UIStackView!
    private var messageStack: UIStackView!
    private var labelMessage: UILabel!
    
    private var rollAnimationTimer: Timer?
    private var holdStartTime: Date?
    private var holdDurationTimer: Timer?
    private let maxHoldTime: TimeInterval = 7
    private var hasFinalizedRoll = false
    
    init(model: DiceModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let model = DiceModel()       // создаём дефолтную модель
        self.model = model
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentedContol()
        setupScoresView()
        setupRollButton()
        setupDiceStack()
        setupLabelMessage()
        
        scoresView.update(players: model.data.players, layout: currentLayout)
        if #available(iOS 17.5, *) {
            lightHaptic = UIImpactFeedbackGenerator(style: .light, view: view)
        } else {
            // Fallback on earlier versions
        }
        title = "DicePro"
        view.backgroundColor = .systemBackground
        view.preservesSuperviewLayoutMargins = true
        let constant: CGFloat = 16 * scaleFactor
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: constant, bottom: 0, trailing: constant)
    }
}

//MARK: Setup UI
extension DiceViewController {
    //MARK: - Navigation Bar SetUp
    func setupNavigationBar() {
        
        if settingsButton == nil {
            settingsButton = UIBarButtonItem(
                image: UIImage(systemName: "gearshape"),
                style: .plain,
                target: self,
                action: #selector(openSettings)
            )
        }
        
        // RESET SCORES
        if resetScoreButton == nil {
            
            resetScoreButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
                style: .plain,
                target: self,
                action: #selector(resetScores)
            )
        }
        resetScoreButton.tintColor = UIColor(red: 0.68, green: 0.02, blue: 0.02, alpha: 1.00)
        resetScoreButton.isEnabled = false
        
        if viewButton == nil {
            viewButton = UIBarButtonItem(
                image: UIImage(systemName: currentLayout.iconName),
                menu: makeViewMenu()
            )
            viewButton.tintColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00)
        } else {
            viewButton.image = UIImage(systemName: currentLayout.iconName)
            viewButton.menu = makeViewMenu()
        }
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItems = [viewButton, space, resetScoreButton]
        
    }
    
    //MARK: - Top Menu Bar SetUp
    func makeViewMenu() -> UIMenu {
        let activeColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00)
        let inactiveColor = UIColor.systemGray
        
        let rowImage = UIImage(systemName: "circle.grid.2x1.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [currentLayout == .row ? activeColor : inactiveColor]))
        let gridImage = UIImage(systemName: "circle.grid.3x3.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [currentLayout == .grid ? activeColor : inactiveColor]))
        
        let rowAction = UIAction(title: "Row", image: rowImage, state: currentLayout == .row ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.currentLayout = .row
            self.applyLayout(.row)
            self.viewButton.image = UIImage(systemName: LayoutType.row.iconName)
            self.viewButton.menu = self.makeViewMenu()
            
        }
        
        let gridAction =  UIAction(title: "Grid", image: gridImage, state: currentLayout == .grid ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            //self.currentLayout = .grid
            self.applyLayout(.grid)
            self.viewButton.image = UIImage(systemName: LayoutType.grid.iconName)
            self.viewButton.menu = self.makeViewMenu()
            
        }
        
        func attributedTitle(_ text: String, isActive: Bool) -> NSAttributedString {
            NSAttributedString(string: text, attributes: [.foregroundColor: isActive ? activeColor : inactiveColor])
        }
        
        rowAction.setValue(attributedTitle("Row", isActive: currentLayout == .row), forKey: "attributedTitle")
        gridAction.setValue(attributedTitle("Grid", isActive: currentLayout == .grid), forKey: "attributedTitle")
        
        return UIMenu(title: "View Mode", children: [rowAction, gridAction])
    }
    
    func applyLayout(_ layout: LayoutType) {
        //UIView.transition(with: scoresView, duration: 0.15, options: .transitionCrossDissolve) { [self] in
            currentLayout = layout
        //}
    }
    
    //MARK: - Roll Button SetUp
    func setupRollButton() {
        rollButton = UIButton(type: .system)
        
        if #available(iOS 26.0, *) {
            var configuration = UIButton.Configuration.glass()
            configuration.attributedTitle = AttributedString(
                "Roll",
                attributes: AttributeContainer([ .font: UIFont.systemFont(ofSize: 24 * scaleFactor, weight: .semibold), .foregroundColor: UIColor.white])
            )
            rollButton.configuration = configuration
            rollButton.backgroundColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00)
        } else {
            rollButton.setTitle("Roll", for: .normal)
            rollButton.titleLabel?.font = UIFont.systemFont(ofSize: 24 * scaleFactor, weight: .semibold)
            rollButton.setTitleColor(.white, for: .normal)
            rollButton.backgroundColor = .systemBlue.withAlphaComponent(0.8)
            
            rollButton.layer.cornerRadius = 32 * scaleFactor
            rollButton.layer.shadowColor = UIColor.label.cgColor
            rollButton.layer.shadowOpacity = 0.05
            rollButton.layer.shadowRadius = 4
            rollButton.layer.shadowOffset = CGSize(width: 0, height: 2.5)
            rollButton.layer.masksToBounds = false
        }
        
        
        rollButton.addTarget(self, action: #selector(rollButtonTapped), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.2   // небольшая задержка
        rollButton.addGestureRecognizer(longPress)
        
        view.addSubview(rollButton)
        
        rollButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rollButton.widthAnchor.constraint(equalToConstant: 135 * scaleFactor),
            rollButton.heightAnchor.constraint(equalToConstant: 64 * scaleFactor),
            rollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120 * scaleFactor)
        ])
        
        
        
    }
    
    //MARK: - Segmented Control SetUp
    func setupSegmentedContol() {
        playerSegmentedControlBarView = UIView()
        playerSegmentedControlBarView.translatesAutoresizingMaskIntoConstraints = false
        playerSegmentedControlBarView.backgroundColor = .systemBackground
        playerSegmentedControlBarView.layer.cornerRadius = 20 * scaleFactor
        
        view.addSubview(playerSegmentedControlBarView)
        
        playerSegmentedControlBarView.layer.shadowColor = UIColor.label.cgColor
        playerSegmentedControlBarView.layer.shadowOpacity = 0.05
        playerSegmentedControlBarView.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        playerSegmentedControlBarView.layer.shadowRadius = 4
        playerSegmentedControlBarView.layer.masksToBounds = false
        
        var items: [String] = []
        for (_,item) in model.data.players.enumerated() {
            items.append(item.name)
        }
        let activeColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00)
        let inactiveColor = UIColor.secondaryLabel
        let fontSize: CGFloat = 14 * scaleFactor
        let activeFont = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        let inactiveFont = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        playerSegmentedControl = UISegmentedControl(items: items)
        playerSegmentedControl.selectedSegmentIndex =  0
        playerSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        playerSegmentedControl.selectedSegmentTintColor = .systemGray6
        playerSegmentedControl.setTitleTextAttributes([.foregroundColor: inactiveColor, .font: inactiveFont], for: .normal)
        playerSegmentedControl.setTitleTextAttributes([.foregroundColor: activeColor, .font: activeFont], for: .selected)
        playerSegmentedControl.subviews.forEach { $0.backgroundColor = .systemBackground }
        playerSegmentedControl.addTarget(self, action: #selector(playerChanged), for: .valueChanged)
        
        playerSegmentedControlBarView.addSubview(playerSegmentedControl)
        
        let scHeight: CGFloat = 32 * scaleFactor
        let constant: CGFloat = 3 * scaleFactor
        let barHeigh: CGFloat = 38 * scaleFactor
        NSLayoutConstraint.activate([
            playerSegmentedControlBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerSegmentedControlBarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            playerSegmentedControlBarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            playerSegmentedControlBarView.heightAnchor.constraint(equalToConstant: barHeigh),
            
            playerSegmentedControl.centerYAnchor.constraint(equalTo: playerSegmentedControlBarView.centerYAnchor),
            playerSegmentedControl.leadingAnchor.constraint(equalTo: playerSegmentedControlBarView.leadingAnchor, constant: constant),
            playerSegmentedControl.trailingAnchor.constraint(equalTo: playerSegmentedControlBarView.trailingAnchor, constant: -constant),
            playerSegmentedControl.heightAnchor.constraint(equalToConstant: scHeight)
        ])
    }
    
    //MARK: - Scores View SetUp
    func setupScoresView() {
        scoresView = ScoresView()
        scoresView.translatesAutoresizingMaskIntoConstraints = false
        scoresView.layer.masksToBounds = false
        view.addSubview(scoresView)
        
        NSLayoutConstraint.activate([
            scoresView.topAnchor.constraint(equalTo: playerSegmentedControlBarView.bottomAnchor, constant: 8),
            scoresView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scoresView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scoresView.heightAnchor.constraint(equalToConstant: 150 * scaleFactor)
        ])
    }
    
    //MARK: - Dices SetUp
    func setupDiceStack() {
        let diceArray = settings.isTwoDicesEnabled ? [dice1, dice2] : [dice1]
        diceStack = UIStackView(arrangedSubviews: diceArray)
        diceStack.translatesAutoresizingMaskIntoConstraints = false
        diceStack.axis = .horizontal
        diceStack.spacing = 16
        diceStack.distribution = .fillEqually
        
        view.addSubview(diceStack)

        dice1.image = UIImage(named: model.setDice(score: model.roll(), color: dice1Color))
        dice2.image = UIImage(named: model.setDice(score: model.roll(), color: dice2Color))
        
        dice1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        NSLayoutConstraint.activate([
            diceStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            diceStack.bottomAnchor.constraint(equalTo: rollButton.topAnchor, constant: -90 * scaleFactor)
        ])
    }
    
    
    //MARK: - Pop Up Label SetUp
    func setupLabelMessage () {
        labelMessage = AnimatedLabel()
        labelMessage.text  = ""
        labelMessage.textColor = .secondaryLabel
        labelMessage.backgroundColor = UIColor.systemGray6
        labelMessage.textAlignment = .center
        labelMessage.font = UIFont.systemFont(ofSize: 18 * scaleFactor, weight: .medium)
        
        labelMessage.layer.cornerRadius = 20
        labelMessage.layer.masksToBounds = true
        labelMessage.alpha = 0
        
        labelMessage.translatesAutoresizingMaskIntoConstraints = false
        
        messageStack = UIStackView()
        messageStack.translatesAutoresizingMaskIntoConstraints = false
        messageStack.axis = .horizontal
        messageStack.alignment = .center
        messageStack.spacing = 1
        messageStack.distribution = .fill
        messageStack.addArrangedSubview(labelMessage)
        
        view.addSubview(messageStack)
        
        NSLayoutConstraint.activate([
            messageStack.bottomAnchor.constraint(equalTo: diceStack.topAnchor),
            messageStack.topAnchor.constraint(equalTo: scoresView.bottomAnchor),
            messageStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelMessage.widthAnchor.constraint(equalToConstant: 70 * scaleFactor),
            labelMessage.heightAnchor.constraint(equalToConstant: 40 * scaleFactor)
        ])
    }
}

//MARK: - Actions
extension DiceViewController {
    //MARK: - PopUp Message Appearance
    //Pop Up Button
    func popUpMessage(text: String) {
        let secondsToDelayOpen = 0.1
        let secondsToDelayClose = 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelayOpen) {
            //UIView.animate(withDuration: secondsToDelayClose, delay: 0.02) {
            self.labelMessage.alpha = 1
            //UIView.transition(with: self.labelMessage, duration: 0.15, options: .transitionCrossDissolve) { [self] in
                self.labelMessage.text = text
            //}
            //}
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelayClose) {
            UIView.animate(withDuration: secondsToDelayClose, delay: 0.2) {
                self.labelMessage.alpha = 0
            }
        }
    }
    
    //MARK: - Roll Button Tap Action
    //Roll button Tapped
    @objc func rollButtonTapped() {
        lightHaptic.impactOccurred()
        
        let roll1 = model.roll()
        let roll2 = model.roll()
        var sum = 0
        var string = ""
        
        dice1.setImageAnimated(UIImage(named: model.setDice(score: roll1, color: dice1Color)))
        dice2.setImageAnimated(UIImage(named: model.setDice(score: roll2, color: dice2Color)))
        
        if settings.isTwoDicesEnabled {
            sum = roll1 + roll2 + 2
            string =  "+ \(sum)"
        } else {
            sum = roll1 + 1
            string = "+ \(sum)"
        }
        
        updateCurrentPlayer(sum: sum)
        popUpMessage(text: string)

    }
    
    //MARK: - Segmented Control Change Segment Action
    @objc func playerChanged() {
        let index = playerSegmentedControl.selectedSegmentIndex
        
        // сбрасываем активность у всех
        for i in model.data.players.indices {
            model.data.players[i].isActive = (i == index)
        }
        
        //UIView.transition(with: scoresView, duration: 0.15, options: .transitionCrossDissolve) { [self] in
            scoresView.updateData(players: model.data.players)
            scoresView.updateLablesColors(activePlayer: index)
        //}
        
    }
    
    //MARK: - Settings Button Tap Action
    @objc func openSettings() {
        let settingsVC = SettingsViewController(settings: settings)
        settingsVC.onSettingsChanged = { [weak self] newSettings in
            guard let self = self else { return  }
            self.settings = newSettings
            self.applySettings(newSettings)
        }
        
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    //MARK: - Reset Button Tap Action
    @objc func resetScores() {
        lightHaptic.impactOccurred()
        model.resetAllScores()
        scoresView.updateData(players: model.data.players)
        
        updateResetButtonState()
    }
}

extension DiceViewController {
    //MARK: - Long Press Roll Button Action
    //Long Press
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRollingAnimation()
            
        case .ended, .cancelled, .failed:
            guard !hasFinalizedRoll else { return }
            finishRollingAnimation()
            
        default:
            break
        }
        
        //model.updateRanks()
        
        //updateResetButtonState()
    }
    
    //Start Animation
    private func startRollingAnimation() {
        lightHaptic.impactOccurred()
        holdStartTime = Date()
        hasFinalizedRoll = false
        
        rollAnimationTimer?.invalidate()
        rollAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.dice1.image = UIImage(named: self?.model.setDice(score: self?.model.roll() ?? 0, color: self?.dice1Color ?? .blackRed) ?? "")
            self?.dice2.image = UIImage(named: self?.model.setDice(score: self?.model.roll() ?? 0, color: self?.dice2Color ?? .WhiteBlue) ?? "")
        }
        
        // контроль максимальных 5 секунд
        holdDurationTimer?.invalidate()
        holdDurationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let elapsed = Date().timeIntervalSince(self.holdStartTime ?? Date())
            
            if elapsed >= self.maxHoldTime {
                hasFinalizedRoll = true
                self.finishRollingAnimation()
            }
        }
    }
    //End Animation
    private func finishRollingAnimation() {
        lightHaptic.impactOccurred()
        rollAnimationTimer?.invalidate()
        holdDurationTimer?.invalidate()
        
        // итоговый бросок
        let r1 = model.roll()
        let r2 = model.roll()
        
        dice1.image = UIImage(named: model.setDice(score: r1, color: dice1Color))
        dice2.image = UIImage(named: model.setDice(score: r2, color: dice2Color))
        
        let sum = (settings.isTwoDicesEnabled ? r1 + r2 + 2 : r1 + 1)
        popUpMessage(text: "+\(sum)")
        
        // обновление данных игрока и UI
        updateCurrentPlayer(sum: sum)
    }
}

extension DiceViewController {
    //MARK: - Update Players Data
    //Current Player
    private func updateCurrentPlayer(sum: Int) {
        let currentIndex = playerSegmentedControl.selectedSegmentIndex
        var currentPlayer = model.data.players[currentIndex]
        
        currentPlayer.currentScore = sum
        currentPlayer.totalScore += sum
        currentPlayer.attempts += 1
        currentPlayer.isActive = true
        
        model.data.players[currentIndex] = currentPlayer
        
        for i in model.data.players.indices where i != currentIndex {
            model.data.players[i].isActive = false
        }
        
        model.updateRanks()
        scoresView.updateData(players: model.data.players)
        updateResetButtonState()
    }
    
    //Settins
    func applySettings(_ newSettings: Settings) {
        settings = newSettings
        
        // 1. Обновляем список игроков по настройкам
        updatePlayers(settings)  // ← ЭТО САМОЕ ВАЖНОЕ
        
        // 2. Обновляем segmented control на основе нового списка игроков
        updateSegmentedControl()
        
        // 3. Обновляем количество кубиков
        updateDiceVisibility()
        
        // 4. Экран всегда включён
        UIApplication.shared.isIdleTimerDisabled = settings.isScreenAlwaysOnEnabled
        
        // 5. Обновляем ScoreView
        scoresView.update(players: model.data.players, layout: currentLayout)
        scoresView.updateLablesColors(activePlayer: playerSegmentedControl.selectedSegmentIndex)
    }
    
    //Players
    private func updatePlayers(_ settings: Settings) {
        var updatedPlayers: [Player] = []
        
        // P1 ALWAYS EXISTS
        updatedPlayers.append(model.data.players[0])
        
        // P2 ALWAYS EXISTS
        updatedPlayers.append(model.data.players[1])
        
        // Player 3
        if settings.isPlayer3Enabled {
            if model.data.players.count < 3 {
                updatedPlayers.append(Player(name: "P3"))
            } else {
                updatedPlayers.append(model.data.players[2])
            }
        }
        
        // Player 4
        if settings.isPlayer4Enabled {
            if model.data.players.count < 4 {
                updatedPlayers.append(Player(name: "P4"))
            } else {
                updatedPlayers.append(model.data.players[3])
            }
        }
        
        model.data.players = updatedPlayers
        
        model.data.updateRanks()
        
        updateSegmentedControl()
    }
}

extension DiceViewController {
    //MARK: - Update UI Elements States
    func updateSegmentedControl() {
        playerSegmentedControl.removeAllSegments()
        
        for (i, player) in model.data.players.enumerated() {
            playerSegmentedControl.insertSegment(withTitle: player.name, at: i, animated: false)
        }
        
        playerSegmentedControl.selectedSegmentIndex = 0
    }
    
    func updateDiceVisibility() {
        if settings.isTwoDicesEnabled {
            if !diceStack.arrangedSubviews.contains(dice2) {
                diceStack.addArrangedSubview(dice2)
            }
            dice2.isHidden = false
            
            // вернуть нормальный размер обоих кубиков
            UIView.animate(withDuration: 0.15) { [self] in
                dice1.transform = .identity
                dice2.transform = .identity
            }
            
        } else {
            if diceStack.arrangedSubviews.contains(dice2) {
                diceStack.removeArrangedSubview(dice2)
                dice2.removeFromSuperview()
            }
            
            // увеличить кубик
            UIView.animate(withDuration: 0.15) {
                self.dice1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }
        }
    }
    
    func updateResetButtonState() {
        resetScoreButton.isEnabled = model.hasScores
    }
}
