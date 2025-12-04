//
//  ViewController.swift
//  DicePro
//
//  Created by Dmitri on 30.11.25.
//

import UIKit

/// Main game screen that displays dice, players, scores and controls.
class DiceViewController: UIViewController {
    
    // MARK: - Game & Settings
    
    /// Game model containing players and dice logic.
    private var model: DiceModel
    
    /// Current user settings loaded from persistent storage.
    var settings = SettingsStorage.load()
    
    // MARK: - UI Elements
    
    /// View that displays attempts, rank and score.
    private var scoresView: ScoresView!
    
    /// Haptic feedback generator for taps and long presses.
    private var lightHaptic: UIImpactFeedbackGenerator!
    
    /// Current layout mode for the scores view (row or grid).
    private var currentLayout: LayoutType = .row {
        didSet {
            guard scoresView != nil else { return }
            UIView.transition(
                with: scoresView,
                duration: 0.15,
                options: .transitionCrossDissolve
            ) { [self] in
                scoresView.update(players: model.data.players, layout: currentLayout)
                scoresView.updateLablesColors(activePlayer: playerSegmentedControl.selectedSegmentIndex)
            }
        }
    }
    
    /// Button for switching layout.
    private var viewButton: UIBarButtonItem!
    
    /// Button that opens the settings screen.
    private var settingsButton: UIBarButtonItem!
    
    /// Button that resets all game scores.
    private var resetScoreButton: UIBarButtonItem!
    
    /// Segmented control used to select the active player.
    private var playerSegmentedControl: UISegmentedControl!
    
    /// Container view for the segmented control with background and shadow.
    private var playerSegmentedControlBarView: UIView!
    
    /// First dice image view.
    private let dice1 = UIImageView()
    
    /// Second dice image view.
    private let dice2 = UIImageView()
    
    /// Dice1 width constraint.
    private var dice1WidthConstraint: NSLayoutConstraint!
    
    /// Dice1 height constraint.
    private var dice1HeightConstraint: NSLayoutConstraint!
    
    /// Dice2 width constraint.
    private var dice2WidthConstraint: NSLayoutConstraint!
    
    /// Dice2 height constraint.
    private var dice2HeightConstraint: NSLayoutConstraint!
    
    /// Color scheme for the first dice.
    private let dice1Color = DiceModel.Dices.WhiteBlue
    
    /// Color scheme for the second dice.
    private let dice2Color = DiceModel.Dices.BlueGrey
    
    /// Main roll button.
    private var rollButton: UIButton!
    
    /// Reserved toolbar reference (currently unused).
    private var rollBar: UIToolbar!
    
    /// Stack view that holds the dice views.
    private var diceStack: UIStackView!
    
    /// Stack view that holds the popup label.
    private var messageStack: UIStackView!
    
    /// Popup label used to show a short “+N” message after roll.
    private var labelMessage: UILabel!
    
    /// Progress bar that indicates long-press duration.
    private var progressView: UIProgressView!
    
    /// Index for the first dice (reserved for future use, e.g. color swapping).
    private var dice1Index = 0
    
    /// Index for the second dice (reserved for future use, e.g. color swapping).
    private var dice2Index = 1
    
    // MARK: - Timers & Long Press State
    
    /// Timer for dice rolling animation during long press.
    private var rollAnimationTimer: Timer?
    
    /// Timestamp when long press started.
    private var holdStartTime: Date?
    
    /// High-frequency timer used to track hold duration and update the progress bar.
    private var holdDurationTimer: Timer?
    
    /// Maximum long-press time in seconds before auto-roll triggers.
    private let maxHoldTime: TimeInterval = 7
    
    /// Indicates that final roll after long press has already been performed.
    private var hasFinalizedRoll = false
    
    // MARK: - Init
    
    /// Designated initializer used when creating controller in code.
    init() {
        self.model = DiceModel()
        self.model.data = GameStorage.load()
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Required initializer for storyboard / nib usage.
    required init?(coder: NSCoder) {
        let model = DiceModel()
        self.model = model
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSegmentedContol()
        setupScoresView()
        setupRollButton()
        setupDiceStack()
        setupProgressBar()
        setupLabelMessage()
        applyDiceSizeBasedOnSettings()
        
        scoresView.update(players: model.data.players, layout: currentLayout)
        
        if #available(iOS 17.5, *) {
            lightHaptic = UIImpactFeedbackGenerator(style: .light, view: view)
        } else {
            // Fallback for earlier iOS versions (no view-based initializer available).
        }
        
        title = "DicePro"
        view.backgroundColor = .systemBackground
        view.preservesSuperviewLayoutMargins = true
        
        let constant: CGFloat = 16 * scaleFactor
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: constant,
            bottom: 0,
            trailing: constant
        )
    }
}

// MARK: - UI Setup

extension DiceViewController {
    
    // MARK: - Navigation Bar Setup
    
    /// Configures navigation bar buttons: settings, layout and reset scores.
    func setupNavigationBar() {
        
        if settingsButton == nil {
            settingsButton = UIBarButtonItem(
                image: UIImage(systemName: "gearshape"),
                style: .plain,
                target: self,
                action: #selector(openSettings)
            )
        }
        
        // Reset Scores button
        if resetScoreButton == nil {
            resetScoreButton = UIBarButtonItem(
                image: UIImage(
                    systemName: "arrow.counterclockwise",
                    withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
                ),
                style: .plain,
                target: self,
                action: #selector(resetScores)
            )
        }
        resetScoreButton.tintColor = AppColors.coolRed
        resetScoreButton.isEnabled = false
        
        if viewButton == nil {
            viewButton = UIBarButtonItem(
                image: UIImage(systemName: currentLayout.iconName),
                menu: makeViewMenu()
            )
            viewButton.tintColor = AppColors.mazarineBlue
        } else {
            viewButton.image = UIImage(systemName: currentLayout.iconName)
            viewButton.menu = makeViewMenu()
        }
        
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItems = [viewButton, space, resetScoreButton]
    }
    
    // MARK: - Layout Menu
    
    /// Builds the layout mode menu (row/grid) for the navigation bar button.
    func makeViewMenu() -> UIMenu {
        let activeColor = AppColors.mazarineBlue
        let inactiveColor = UIColor.systemGray
        
        let rowImage = UIImage(
            systemName: "circle.grid.2x1.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                paletteColors: [currentLayout == .row ? activeColor : inactiveColor]
            )
        )
        let gridImage = UIImage(
            systemName: "circle.grid.3x3.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                paletteColors: [currentLayout == .grid ? activeColor : inactiveColor]
            )
        )
        
        let rowAction = UIAction(
            title: "Row",
            image: rowImage,
            state: currentLayout == .row ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            self.applyLayout(.row)
            self.viewButton.image = UIImage(systemName: LayoutType.row.iconName)
            self.viewButton.menu = self.makeViewMenu()
        }
        
        let gridAction = UIAction(
            title: "Grid",
            image: gridImage,
            state: currentLayout == .grid ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            self.applyLayout(.grid)
            self.viewButton.image = UIImage(systemName: LayoutType.grid.iconName)
            self.viewButton.menu = self.makeViewMenu()
        }
        
        func attributedTitle(_ text: String, isActive: Bool) -> NSAttributedString {
            NSAttributedString(
                string: text,
                attributes: [.foregroundColor: isActive ? activeColor : inactiveColor]
            )
        }
        
        rowAction.setValue(
            attributedTitle("Row", isActive: currentLayout == .row),
            forKey: "attributedTitle"
        )
        gridAction.setValue(
            attributedTitle("Grid", isActive: currentLayout == .grid),
            forKey: "attributedTitle"
        )
        
        return UIMenu(title: "View Mode", children: [rowAction, gridAction])
    }
    
    /// Applies selected layout mode to the scores view.
    func applyLayout(_ layout: LayoutType) {
        currentLayout = layout
    }
    
    // MARK: - Roll Button Setup
    
    /// Configures the main Roll button and the long-press gesture.
    func setupRollButton() {
        rollButton = UIButton(type: .system)
        let size = 24 * scaleFactor
        if #available(iOS 26.0, *) {
            var configuration = UIButton.Configuration.glass()
            configuration.attributedTitle = AttributedString(
                "Roll",
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: size, weight: .semibold),
                    .foregroundColor: UIColor.white
                ])
            )
            rollButton.configuration = configuration
            rollButton.backgroundColor = AppColors.mazarineBlue
        } else {
            rollButton.setTitle("Roll", for: .normal)
            rollButton.titleLabel?.font = UIFont.systemFont(
                ofSize: size,
                weight: .semibold
            )
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
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.2
        rollButton.addGestureRecognizer(longPress)
        
        view.addSubview(rollButton)
        
        let c: CGFloat = 100 * scaleFactor
        let bOffset: CGFloat = isSmallScreen ? 0.4 * c : c
        let w: CGFloat = 135 * scaleFactor
        let h: CGFloat  = 64 * scaleFactor
        rollButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rollButton.widthAnchor.constraint(equalToConstant: w),
            rollButton.heightAnchor.constraint(equalToConstant: h),
            rollButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rollButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bOffset)
        ])
    }
    
    // MARK: - Segmented Control Setup
    
    /// Configures the player selection segmented control.
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
        for (_, item) in model.data.players.enumerated() {
            items.append(item.name)
        }
        
        let activeColor = AppColors.mazarineBlue
        let inactiveColor = UIColor.secondaryLabel
        let size: CGFloat = 14 * scaleFactor
        let activeFont = UIFont.systemFont(ofSize: size, weight: .semibold)
        let inactiveFont = UIFont.systemFont(ofSize: size, weight: .medium)
        
        playerSegmentedControl = UISegmentedControl(items: items)
        playerSegmentedControl.selectedSegmentIndex = 0
        playerSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        playerSegmentedControl.selectedSegmentTintColor = .systemGray6
        playerSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: inactiveColor, .font: inactiveFont],
            for: .normal
        )
        playerSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: activeColor, .font: activeFont],
            for: .selected
        )
        playerSegmentedControl.subviews.forEach { $0.backgroundColor = .systemBackground }
        playerSegmentedControl.addTarget(
            self,
            action: #selector(playerChanged),
            for: .valueChanged
        )
        
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
    
    // MARK: - Scores View Setup
    
    /// Creates and positions the scores view container.
    func setupScoresView() {
        scoresView = ScoresView()
        scoresView.translatesAutoresizingMaskIntoConstraints = false
        scoresView.layer.masksToBounds = false
        view.addSubview(scoresView)
        
        let c: CGFloat = 8 * scaleFactor
        let h: CGFloat = 150 * scaleFactor
        NSLayoutConstraint.activate([
            scoresView.topAnchor.constraint(equalTo: playerSegmentedControlBarView.bottomAnchor, constant: c),
            scoresView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scoresView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scoresView.heightAnchor.constraint(equalToConstant: h)
        ])
    }
    
    // MARK: - Dice Stack Setup
    
    /// Creates the dice stack and sets initial images and gestures.
    func setupDiceStack() {
        let diceArray = settings.isTwoDicesEnabled ? [dice1, dice2] : [dice1]
        diceStack = UIStackView(arrangedSubviews: diceArray)
        diceStack.translatesAutoresizingMaskIntoConstraints = false
        diceStack.axis = .horizontal
        diceStack.spacing = 16 * scaleFactor
        diceStack.distribution = .fillEqually
        diceStack.alignment = .center
        
        view.addSubview(diceStack)
        addSwipeGesturesToDice()
        
        dice1.image = UIImage(named: model.setDice(score: model.roll(), color: dice1Color))
        dice2.image = UIImage(named: model.setDice(score: model.roll(), color: dice2Color))
        
        //dice1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        //let c: CGFloat = 90 * scaleFactor
        
        let baseSize: CGFloat = 160 * scaleFactor

        dice1WidthConstraint  = dice1.widthAnchor.constraint(equalToConstant: baseSize)
        dice1HeightConstraint = dice1.heightAnchor.constraint(equalToConstant: baseSize)
        dice2WidthConstraint  = dice2.widthAnchor.constraint(equalToConstant: baseSize)
        dice2HeightConstraint = dice2.heightAnchor.constraint(equalToConstant: baseSize)

        // для начала второй кубик тоже настраиваем по размеру
        dice2WidthConstraint.isActive = true
        dice2HeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            diceStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            diceStack.bottomAnchor.constraint(equalTo: rollButton.topAnchor),
            diceStack.topAnchor.constraint(equalTo: scoresView.bottomAnchor),
            dice1WidthConstraint,
            dice1HeightConstraint
        ])
        
        //let scale =  isSmallScreen ? scaleFactor * 0.95 : scaleFactor
       // dice1.transform = CGAffineTransform(scaleX: scale, y: scale)
        //dice1.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    // MARK: - Progress Bar Setup
    
    /// Configures the progress bar used for long-press indication.
    func setupProgressBar() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.progressTintColor = AppColors.coolRed
        progressView.trackTintColor = .systemGray6
        progressView.alpha = 0
        
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let c: CGFloat = 40 * scaleFactor
        let w: CGFloat = 200 * scaleFactor
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: w),
            progressView.topAnchor.constraint(equalTo: dice1.bottomAnchor, constant: c)
        ])
    }
    
    // MARK: - Popup Label Setup
    
    /// Prepares the floating message label that shows `+N` after rolls.
    func setupLabelMessage() {
        labelMessage = AnimatedLabel()
        labelMessage.text = ""
        labelMessage.textColor = .secondaryLabel
        labelMessage.backgroundColor = UIColor.systemGray6
        labelMessage.textAlignment = .center
        labelMessage.font = UIFont.systemFont(ofSize: 18 * scaleFactor, weight: .medium)
        
        labelMessage.layer.cornerRadius = 20 * scaleFactor
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
        
        let w: CGFloat = 70 * scaleFactor
        let h: CGFloat = 40 * scaleFactor
        NSLayoutConstraint.activate([
            messageStack.bottomAnchor.constraint(equalTo: dice1.topAnchor),
            messageStack.topAnchor.constraint(equalTo: scoresView.bottomAnchor),
            messageStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelMessage.widthAnchor.constraint(equalToConstant: w),
            labelMessage.heightAnchor.constraint(equalToConstant: h)
        ])
    }
}

// MARK: - Actions

extension DiceViewController {
    
    // MARK: - Popup Message
    
    /// Shows a temporary popup message above the dice stack.
    func popUpMessage(text: String) {
        let secondsToDelayOpen = 0.1
        let secondsToDelayClose = 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelayOpen) {
            self.labelMessage.alpha = 1
            self.labelMessage.text = text
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelayClose) {
            UIView.animate(withDuration: secondsToDelayClose, delay: 0.2) {
                self.labelMessage.alpha = 0
            }
        }
    }
    
    // MARK: - Roll Button Tap
    
    /// Handles a single tap on the roll button.
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
            string = "+ \(sum)"
        } else {
            sum = roll1 + 1
            string = "+ \(sum)"
        }
        
        updateCurrentPlayer(sum: sum)
        popUpMessage(text: string)
        
        GameStorage.save(model.data)
    }
    
    // MARK: - Player Selection Changed
    
    /// Called when user selects a different player in the segmented control.
    @objc func playerChanged() {
        let index = playerSegmentedControl.selectedSegmentIndex
        
        // Reset active flag for all players and set only the selected one.
        for i in model.data.players.indices {
            model.data.players[i].isActive = (i == index)
        }
        
        UIView.transition(
            with: scoresView,
            duration: 0.15,
            options: .transitionCrossDissolve
        ) { [self] in
            scoresView.updateData(players: model.data.players)
            scoresView.updateLablesColors(activePlayer: index)
        }
    }
    
    // MARK: - Open Settings
    
    /// Presents the settings screen and applies changes via callback.
    @objc func openSettings() {
        let settingsVC = SettingsViewController(settings: settings)
        settingsVC.onSettingsChanged = { [weak self] newSettings in
            guard let self = self else { return }
            SettingsStorage.save(newSettings)
            self.applySettings(newSettings)
        }
        
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: - Reset Scores Button
    
    /// Shows an alert to confirm resetting all scores.
    @objc func resetScores() {
        let alert = UIAlertController(
            title: "Reset Scores",
            message: "Are you sure you want to reset all scores?",
            preferredStyle: .alert
        )
        
        // Confirm reset
        let yesAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.lightHaptic?.impactOccurred()
            
            self.model.resetAllScores()
            GameStorage.save(model.data)
            
            self.scoresView.updateData(players: self.model.data.players)
            self.updateResetButtonState()
        }
        
        // Cancel reset
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Long Press Handling

extension DiceViewController {
    
    /// Handles long-press gesture on the roll button to show animation and progress.
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRollingAnimation()
            
        case .ended, .cancelled, .failed:
            progressView.setAlphaAnimated(0.0)
            progressView.progress = 0
            guard !hasFinalizedRoll else { return }
            finishRollingAnimation()
            
        default:
            break
        }
    }
    
    /// Starts dice rolling animation and progress bar updating during long press.
    private func startRollingAnimation() {
        lightHaptic.impactOccurred()
        holdStartTime = Date()
        hasFinalizedRoll = false
        progressView.setAlphaAnimated(1.0)
        
        rollAnimationTimer?.invalidate()
        rollAnimationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.dice1.image = UIImage(
                named: self?.model.setDice(
                    score: self?.model.roll() ?? 0,
                    color: self?.dice1Color ?? .blackRed
                ) ?? ""
            )
            self?.dice2.image = UIImage(
                named: self?.model.setDice(
                    score: self?.model.roll() ?? 0,
                    color: self?.dice2Color ?? .WhiteBlue
                ) ?? ""
            )
        }
        
        // Track hold duration and update progress bar.
        holdDurationTimer?.invalidate()
        holdDurationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let elapsed = Date().timeIntervalSince(self.holdStartTime ?? Date())
            progressView.progress = Float(elapsed / maxHoldTime)
            
            if elapsed >= self.maxHoldTime {
                hasFinalizedRoll = true
                self.finishRollingAnimation()
            }
        }
    }
    
    /// Finalizes dice roll after long press ends or time limit is reached.
    private func finishRollingAnimation() {
        lightHaptic.impactOccurred()
        rollAnimationTimer?.invalidate()
        holdDurationTimer?.invalidate()
        
        // Final roll
        let r1 = model.roll()
        let r2 = model.roll()
        
        dice1.image = UIImage(named: model.setDice(score: r1, color: dice1Color))
        dice2.image = UIImage(named: model.setDice(score: r2, color: dice2Color))
        
        let sum = (settings.isTwoDicesEnabled ? r1 + r2 + 2 : r1 + 1)
        popUpMessage(text: "+\(sum)")
        
        // Update player scores and UI
        updateCurrentPlayer(sum: sum)
    }
}

// MARK: - Game & Settings Updates

extension DiceViewController {
    
    // MARK: - Player Data
    
    /// Updates current player stats with new roll result.
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
    
    // MARK: - Apply Settings
    
    /// Applies new settings to UI and game state.
    func applySettings(_ newSettings: Settings) {
        settings = newSettings
        
        // 1. Update players list according to settings.
        updatePlayers(settings)
        
        // 2. Rebuild segmented control from updated players.
        updateSegmentedControl()
        
        // 3. Update dice count and size.
        updateDiceVisibility()
        applyDiceSizeBasedOnSettings()
        
        // 4. Keep the screen awake if enabled in settings.
        UIApplication.shared.isIdleTimerDisabled = settings.isScreenAlwaysOnEnabled
        
        // 5. Refresh scores view with current layout and active player.
        scoresView.update(players: model.data.players, layout: currentLayout)
        scoresView.updateLablesColors(activePlayer: playerSegmentedControl.selectedSegmentIndex)
    }
    
    /// Updates the players array based on the current settings
    /// (enabling or disabling Player 3 and Player 4).
    private func updatePlayers(_ settings: Settings) {
        var updatedPlayers: [Player] = []
        
        // Player 1 always exists
        updatedPlayers.append(model.data.players[0])
        
        // Player 2 always exists
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

// MARK: - Swipes

extension DiceViewController {
    
    /// Adds left and right swipe gestures to the first dice.
    func addSwipeGesturesToDice() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        left.direction = .left
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        right.direction = .right
        
        dice1.isUserInteractionEnabled = true
        dice1.addGestureRecognizer(left)
        dice1.addGestureRecognizer(right)
    }
    
    /// Handles swipe gestures on the first dice (reserved for future behavior).
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // Future behavior for left swipe.
        } else {
            // Future behavior for right swipe.
        }
    }
}

// MARK: - UI State Helpers

extension DiceViewController {
    
    /// Rebuilds segmented control titles based on current players list.
    func updateSegmentedControl() {
        playerSegmentedControl.removeAllSegments()
        
        for (i, player) in model.data.players.enumerated() {
            playerSegmentedControl.insertSegment(withTitle: player.name, at: i, animated: false)
        }
        
        playerSegmentedControl.selectedSegmentIndex = 0
    }
    
    /// Shows or hides the second dice depending on settings and animates size changes.
    func updateDiceVisibility() {
        let normalSize: CGFloat = 160 * scaleFactor
        let bigSize: CGFloat = 200 * scaleFactor

        if settings.isTwoDicesEnabled {
            if !diceStack.arrangedSubviews.contains(dice2) {
                diceStack.addArrangedSubview(dice2)
            }
            dice2.isHidden = false

            UIView.animate(withDuration: 0.2) {
                self.dice1WidthConstraint.constant = normalSize
                self.dice1HeightConstraint.constant = normalSize
                self.dice2WidthConstraint.constant = normalSize
                self.dice2HeightConstraint.constant = normalSize
                self.view.layoutIfNeeded()
            }

        } else {
            if diceStack.arrangedSubviews.contains(dice2) {
                diceStack.removeArrangedSubview(dice2)
                dice2.removeFromSuperview()
            }

            UIView.animate(withDuration: 0.2) {
                self.dice1WidthConstraint.constant = bigSize
                self.dice1HeightConstraint.constant = bigSize
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /// Enables or disables the reset button depending on whether scores exist.
    func updateResetButtonState() {
        resetScoreButton.isEnabled = model.hasScores
    }
    
    /// Applies size transform to dice based on current settings.
    func applyDiceSizeBasedOnSettings() {
        let normalSize: CGFloat = 160 * scaleFactor
        let bigSize: CGFloat = 200 * scaleFactor

        UIView.animate(withDuration: 0.2) {
            if self.settings.isTwoDicesEnabled {
                // два кубика — оба нормального размера
                self.dice1WidthConstraint.constant = normalSize
                self.dice1HeightConstraint.constant = normalSize
                self.dice2WidthConstraint.constant = normalSize
                self.dice2HeightConstraint.constant = normalSize
            } else {
                // один кубик — увеличиваем первый
                self.dice1WidthConstraint.constant = bigSize
                self.dice1HeightConstraint.constant = bigSize
                self.dice2WidthConstraint.constant = normalSize
                self.dice2HeightConstraint.constant = normalSize
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
