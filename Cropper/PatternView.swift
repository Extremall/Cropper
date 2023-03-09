//
//  PatternView.swift
//  Cropper
//
//  Created by Alexander Naumenko on 20/02/2023.
//

import UIKit

class PatternView: UIView {
    
    lazy var viewHor: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    lazy var viewVer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.viewVer.alpha = 1
        self.viewHor.alpha = 1
    }
    
    func hide() {
        self.viewVer.alpha = 0
        self.viewHor.alpha = 0
    }
    
    func showAnimated() {
        UIView.animate(withDuration: 0.1) {
            self.show()
        }
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: 0.1) {
            self.hide()
        }
    }
    
    func commonInit() {
        self.addSubview(viewHor)
        self.addSubview(viewVer)
        
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            viewHor.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0/3),
            viewVer.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/3),
            
            viewHor.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -1),
            viewHor.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1),
            viewHor.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            viewVer.topAnchor.constraint(equalTo: self.topAnchor, constant: -1),
            viewVer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
            viewVer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
}
