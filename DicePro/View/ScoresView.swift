//
//  ValueView.swift
//  DicePro
//
//  Created by Dmitri on 01.12.25.
//

import UIKit

// MARK: - ScoresView
/// Displays players' attempts, scores and ranks in two layout modes:
/// - Row: focuses on the active player
/// - Grid: shows all players equally
final class ScoresView: UIView {
    
    // MARK: - Private Properties
    private var labels: [[UILabel]] = []       // Matrix of labels (per player / per value)
    private var verticalStack = UIStackView()  // Root container stack
    private(set) var currentLayout: LayoutType = .row
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    // MARK: - Appearance
    /// Sets up the rounded background and shadow style.
    private func setupAppearance() {
        let radius: CGFloat = 20 * scaleFactor
        backgroundColor = .systemBackground
        layer.cornerRadius = radius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
    }
    
    // MARK: - Update From Controller
    /// Rebuilds the view according to current players and layout.
    func update(players: [Player], layout: LayoutType) {
        currentLayout = layout
        rebuildLayout(players: players)
    }
    
    /// Updates values inside existing labels without rebuilding the layout.
    func updateData(players: [Player]) {
        guard !labels.isEmpty else { return }
        
        if currentLayout == .row {
            let activeIndex = players.firstIndex(where: { $0.isActive }) ?? 0
            let p = players[activeIndex]
            
            labels[0][0].text = "\(p.attempts.formatted(.number))"
            labels[0][1].text = "\(p.rank)"
            labels[0][2].text = "\(p.totalScore.formatted(.number))"
            
        } else {
            for (i, p) in players.enumerated() {
                labels[i][0].text = "\(p.attempts.formatted(.number))"
                labels[i][1].text = "\(p.totalScore.formatted(.number))"
                labels[i][2].text = "\(p.rank)"
            }
        }
    }
}


// MARK: - UI Builders
extension ScoresView {
    
    // MARK: Create Label
    /// Creates a single animated label with default formatting.
    func createLabel(alignment: NSTextAlignment) -> UILabel {
        let lbl = AnimatedLabel()
        lbl.text = "0"
        lbl.textAlignment = alignment
        lbl.font = .systemFont(ofSize: 20 * scaleFactor, weight: .medium)
        lbl.textColor = .label
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        return lbl
    }
    
    // MARK: Create Horizontal Stack
    /// Builds a horizontal row of labels.
    func makeHStack(_ labels: [UILabel]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 10
        stack.distribution = .fill
        return stack
    }
    
    // MARK: Create Vertical Stack
    func makeVStack(distribution: UIStackView.Distribution) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    // MARK: - Layout Construction
    /// Completely rebuilds the layout for the given players.
    func rebuildLayout(players: [Player]) {
        
        // 1. Remove old content
        verticalStack.removeFromSuperview()
        labels.removeAll()
        
        let distribution: UIStackView.Distribution =
        currentLayout == .row ? .fill : .fillEqually
        
        verticalStack = makeVStack(distribution: distribution)
        addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // 2. Build based on layout mode
        if currentLayout == .row {
            
            labels = Array(repeating: [], count: 1)
            
            let attempts = createLabel(alignment: .left)
            let rank = createLabel(alignment: .right)
            let score = createLabel(alignment: .right)
            
            labels[0].append(contentsOf: [attempts, rank, score])
            
            let top = makeHStack([attempts, rank])
            let bottom = makeHStack([score])
            
            verticalStack.addArrangedSubview(top)
            verticalStack.addArrangedSubview(bottom)
            
        } else {
            
            labels = Array(repeating: [], count: players.count)
            
            for i in 0..<players.count {
                let attempts = createLabel(alignment: .left)
                let score = createLabel(alignment: .right)
                let rank = createLabel(alignment: .right)
                
                rank.widthAnchor.constraint(equalToConstant: 60).isActive = true
                
                labels[i].append(contentsOf: [attempts, score, rank])
                
                let row = makeHStack([attempts, score, rank])
                verticalStack.addArrangedSubview(row)
            }
        }
        
        updateData(players: players)
        updateLablesColors()
    }
    
    // MARK: - Label Styling
    /// Applies colors and fonts depending on active player and layout mode.
    func updateLablesColors(activePlayer: Int? = nil) {
        
        let attemptColor = AppColors.coolRed
        let rankColor = AppColors.darkGold.withAlphaComponent(0.5)
        let scoreColor = AppColors.mazarineBlue
        
        let firstMaxFont: CGFloat = 60 * scaleFactor
        let secondMaxFont: CGFloat = 45 * scaleFactor
        let minFont: CGFloat = 26 * scaleFactor
        let secondSize: CGFloat = secondMaxFont - (secondMaxFont - minFont) / 4 * Double(labels.count)
        
        let attemptFont: UIFont =
        currentLayout == .row ? .rounded(ofSize: secondMaxFont, weight: .medium)
        : .rounded(ofSize: secondSize, weight: .medium)
        
        let rankFont = attemptFont
        let scoreFont: UIFont =
        currentLayout == .row ? .rounded(ofSize: firstMaxFont, weight: .medium)
        : .rounded(ofSize: secondSize, weight: .medium)
        
        if currentLayout == .row {
            
            for (_, label) in labels.enumerated() {
                label[0].textColor = attemptColor
                label[2].textColor = scoreColor
                label[1].textColor = rankColor
                
                label[0].font = attemptFont
                label[2].font = scoreFont
                label[1].font = rankFont
            }
            
        } else {
            
            for (index, label) in labels.enumerated() {
                if index == (activePlayer ?? 0) {
                    label[0].textColor = attemptColor
                    label[1].textColor = scoreColor
                    label[2].textColor = rankColor
                } else {
                    label[0].textColor = .tertiaryLabel
                    label[1].textColor = .tertiaryLabel
                    label[2].textColor = .tertiaryLabel
                }
                
                label[0].font = attemptFont
                label[1].font = scoreFont
                label[2].font = rankFont
            }
        }
    }
}


// MARK: - Rounded Font Helper
extension UIFont {
    /// Creates a system rounded font if available.
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = base.fontDescriptor.withDesign(.rounded)
        return UIFont(descriptor: descriptor ?? base.fontDescriptor, size: size)
    }
}
