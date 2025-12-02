//
//  ValueView.swift
//  DicePro
//
//  Created by Dmitri  on 01.12.25.
//

import UIKit

final class ScoresView: UIView {

    // MARK: - Private Properties
    private var labels: [[UILabel]] = []
    private var verticalStack = UIStackView()
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
    private func setupAppearance() {
        let radius: CGFloat = 20 * scaleFactor
        backgroundColor = .systemBackground
        layer.cornerRadius = radius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
    }

    // MARK: - Update from Controller
    func update(players: [Player], layout: LayoutType) {
        currentLayout = layout
        rebuildLayout(players: players)
    }

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

// MARK: - Private UI Builders
 extension ScoresView {

    func createLabel(alignment: NSTextAlignment) -> UILabel {
        let lbl = UILabel()
        lbl.text = "0"
        lbl.textAlignment = alignment
        lbl.font = .systemFont(ofSize: 20 * scaleFactor, weight: .medium)
        lbl.textColor = .label
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        return lbl
    }

    func makeHStack(_ labels: [UILabel]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 10
        stack.distribution = .fill
        return stack
    }

    func rebuildLayout(players: [Player]) {

        // 1. Clear previous content
        verticalStack.removeFromSuperview()
        labels.removeAll()

        // 2. Create fresh vertical stack
        verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 6
        verticalStack.distribution = .fill
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        // 3. Build rows depending on layout
        if currentLayout == .row {

            labels = Array(repeating: [], count: 1)

            let attempts = createLabel(alignment: .left)
            let rank = createLabel(alignment: .right)
            let score = createLabel(alignment: .right)
            
//            attempts.textColor = .secondaryLabel//UIColor(red: 0.68, green: 0.02, blue: 0.02, alpha: 1.00) //red
//            rank.textColor = UIColor(red: 0.60, green: 0.56, blue: 0.00, alpha: 1.00) //gold
//            score.textColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00) // blue
//            
//            attempts.font = .systemFont(ofSize: 40, weight: .medium)
//            rank.font = .systemFont(ofSize: 40, weight: .medium)
//            score.font = .systemFont(ofSize: 50, weight: .medium)

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
                
//                attempts.textColor = .secondaryLabel//UIColor(red: 0.68, green: 0.02, blue: 0.02, alpha: 1.00) //red
//                rank.textColor = .tertiaryLabel//UIColor(red: 0.60, green: 0.56, blue: 0.00, alpha: 1.00) //gold
//                score.textColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00) // blue
//                
//                attempts.font = .systemFont(ofSize: 40, weight: .medium)
//                rank.font = .systemFont(ofSize: 40, weight: .medium)
//                score.font = .systemFont(ofSize: 40, weight: .medium)
                
                rank.widthAnchor.constraint(equalToConstant: 60).isActive = true

                labels[i].append(contentsOf: [attempts, score, rank])

                let row = makeHStack([attempts, score, rank])
                verticalStack.addArrangedSubview(row)
            }
        }
        
        updateData(players: players)
        updateLablesColors()
    }
    
    func updateLablesColors(activePlayer: Int? = nil) {
        let attemptColor: UIColor = UIColor(red: 0.68, green: 0.02, blue: 0.02, alpha: 1.00).withAlphaComponent(0.4) //red
        let rankColor: UIColor = UIColor(red: 0.60, green: 0.56, blue: 0.00, alpha: 1.00).withAlphaComponent(0.4) //gold
        let scoreColor: UIColor = UIColor(red: 0.03, green: 0.18, blue: 0.60, alpha: 1.00) // blue
        
        let attemptFont: UIFont = currentLayout == .row ? .systemFont(ofSize: 40, weight: .medium) : .systemFont(ofSize: 40, weight: .medium)
        let rankFont: UIFont = currentLayout == .row ? .systemFont(ofSize: 40, weight: .medium) : .systemFont(ofSize: 40, weight: .medium)
        let scoreFont: UIFont = currentLayout == .row ? .systemFont(ofSize: 50, weight: .medium) : .systemFont(ofSize: 40, weight: .medium)
        
        if currentLayout == .row {
            for (_,label) in labels.enumerated() {
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

