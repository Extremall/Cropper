//
//  ViewController.swift
//  Cropper
//
//  Created by Alexander Naumenko on 17/02/2023.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var cropperView: CropperView = {
        let view = CropperView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var resultImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var buttonToogle: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Toogle", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(buttonToggleTouchedUpInside), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .cyan
        
        view.addSubview(cropperView)
        NSLayoutConstraint.activate([
            cropperView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            cropperView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cropperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cropperView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        cropperView.sourceImage = UIImage(named: "1")
        
        view.addSubview(resultImage)
        NSLayoutConstraint.activate([
            resultImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 420),
            resultImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultImage.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        cropperView.onChangeResult = { image in
            self.resultImage.image = image
        }
        
        view.addSubview(buttonToogle)
        NSLayoutConstraint.activate([
            buttonToogle.topAnchor.constraint(equalTo: cropperView.bottomAnchor, constant: 5),
            buttonToogle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            buttonToogle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            buttonToogle.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

// MARK: - Actions

extension ViewController {
    @objc func buttonToggleTouchedUpInside() {
        cropperView.toogleView()
    }
}

