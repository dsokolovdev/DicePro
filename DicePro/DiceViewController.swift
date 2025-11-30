//
//  ViewController.swift
//  DicePro
//
//  Created by Dmitri  on 30.11.25.
//

import UIKit

class DiceViewController: UIViewController {
    var model = DiceModel()
    
    var rollBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRollButton()
        
        
        view.preservesSuperviewLayoutMargins = true
        let constant: CGFloat = 16 * scaleFactor
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: constant, bottom: 0, trailing: constant)
    }


}

extension DiceViewController {
    //MARK: Setup UI
    func setupRollButton() {
        let rollButton = UIBarButtonItem(title: " Roll ", style: .plain, target: self, action: #selector(rollButtonTapped))
        
        rollBar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        rollBar.items = [space, rollButton, space]
        
        rollBar.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
        view.addSubview(rollBar)
        
        rollBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rollBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150 * scaleFactor),
            rollBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            rollBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    //MARK: Actions
    
    @objc func rollButtonTapped() {
       let result = model.roll()
        print(result)
    }
}

