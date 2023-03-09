//
//  CropperView.swift
//  Cropper
//
//  Created by Alexander Naumenko on 18/02/2023.
//

import UIKit

class CropperView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bouncesZoom = true
        scrollView.isUserInteractionEnabled = true
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var patternView: PatternView = {
        let view = PatternView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var imageWidthConstraint: NSLayoutConstraint!
    var imageHeightConstraint: NSLayoutConstraint!
    
    var leftPatternConstraint: NSLayoutConstraint!
    var rightPatternConstraint: NSLayoutConstraint!
    var topPatternConstraint: NSLayoutConstraint!
    var bottomPatternConstraint: NSLayoutConstraint!
    
    var isNeedLoadSource: Bool = false
    
    var resultImage: UIImage?
    
    var timer: Timer?
    
    var onChangeResult: ((UIImage?) -> Void)?
    
    var maxWidthRatio: CGFloat = 1.5 {
        didSet {
            initConstraints()
        }
    }
    
    var maxHeightRatio: CGFloat = 1.2 {
        didSet {
            initConstraints()
        }
    }
    
    var sourceImage: UIImage? {
        didSet {
            imageView.image = sourceImage
            
            initConstraints()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isNeedLoadSource {
            initConstraints()
        }
    }
    
    func initConstraints() {
        guard let cgImage = sourceImage?.cgImage else { return }
        
        if (scrollView.frame.width == 0 || scrollView.frame.height == 0) {
            isNeedLoadSource = true
            return
        }
        
        isNeedLoadSource = false
        
        let w = cgImage.width
        let h = cgImage.height
        
        var rw: CGFloat = CGFloat(w) / scrollView.frame.width
        var rh: CGFloat = CGFloat(h) / scrollView.frame.height
        
        let wRatio = CGFloat(w) / CGFloat(h)
        if wRatio > maxWidthRatio {
            let koef = wRatio / maxWidthRatio
            rw /= koef
        }
        
        let hRatio = CGFloat(h) / CGFloat(w)
        if hRatio > maxHeightRatio {
            let koef = hRatio / maxHeightRatio
            rh /= koef
        }
        
        let r = max(rw, rh)
        
        imageWidthConstraint.constant = CGFloat(w) / r
        imageHeightConstraint.constant = CGFloat(h) / r
        
        scrollView.contentSize = CGSize(width: imageWidthConstraint.constant,
                                        height: imageHeightConstraint.constant)
        
        centerContent(contentSize: CGSize(width: imageWidthConstraint.constant, height: imageHeightConstraint.constant))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.addSubview(scrollView)
        scrollView.addSubview(imageView)
        self.addSubview(patternView)
        
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        
        leftPatternConstraint = patternView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        rightPatternConstraint = patternView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        topPatternConstraint = patternView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        bottomPatternConstraint = patternView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageWidthConstraint,
            imageHeightConstraint,
            
            leftPatternConstraint,
            rightPatternConstraint,
            topPatternConstraint,
            bottomPatternConstraint
        ])
        
        patternView.hide()
    }
    
    func toogleView() {
        if scrollView.contentSize.width >= scrollView.frame.width && scrollView.contentSize.height > scrollView.frame.height {
            minView()
        } else {
            squareView()
        }
    }
    
    func squareView() {
        if imageWidthConstraint.constant < scrollView.frame.width {
            scrollView.zoomScale = scrollView.frame.width / imageWidthConstraint.constant
        } else {
            scrollView.zoomScale = scrollView.frame.height / imageHeightConstraint.constant
        }
    }
    
    func minView() {
        scrollView.zoomScale = 1.0
    }
    
    func cropResult() {
        
        guard scrollView.frame.width > 0,
              scrollView.frame.height > 0,
              scrollView.contentSize.width > 0,
              scrollView.contentSize.height > 0,
              sourceImage != nil else { return }
        
        var lr = scrollView.contentOffset.x / scrollView.contentSize.width
        var tr = scrollView.contentOffset.y / scrollView.contentSize.height
        var wr = scrollView.frame.width / scrollView.contentSize.width
        var hr = scrollView.frame.height / scrollView.contentSize.height
        
        if wr > 1 {
            wr = 1
            lr = 0
        }
        
        if hr > 1 {
            hr = 1
            tr = 0
        }
        
        guard let cgImage = sourceImage?.cgImage else { return }
        
        let left = lr * CGFloat(cgImage.width)
        let top = tr * CGFloat(cgImage.height)
        let width = wr * CGFloat(cgImage.width)
        let height = hr * CGFloat(cgImage.height)
        
        let res = sourceImage?.cgImage?.cropping(to: CGRect(x: left, y: top, width: width, height: height))
        resultImage = UIImage(cgImage: res!)
        
        onChangeResult?(resultImage)
    }
    
    func setPattern() {
        guard scrollView.frame.width > 0,
              scrollView.frame.height > 0,
              scrollView.contentSize.width > 0,
              scrollView.contentSize.height > 0,
              sourceImage != nil else { return }
        
        if scrollView.contentOffset.x < 0 {
            leftPatternConstraint.constant = -scrollView.contentOffset.x
        } else {
            leftPatternConstraint.constant = 0
        }
        if scrollView.contentOffset.y < 0 {
            topPatternConstraint.constant = -scrollView.contentOffset.y
        } else {
            topPatternConstraint.constant = 0
        }
        
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height {
            bottomPatternConstraint.constant = -(scrollView.contentOffset.y + scrollView.frame.height - scrollView.contentSize.height)
        } else {
            bottomPatternConstraint.constant = 0
        }
        
        if scrollView.contentOffset.x + scrollView.frame.width > scrollView.contentSize.width {
            rightPatternConstraint.constant = -(scrollView.contentOffset.x + scrollView.frame.width - scrollView.contentSize.width)
        } else {
            rightPatternConstraint.constant = 0
        }
    }
}

extension CropperView: UIScrollViewDelegate {
    
    func fireCheckingForPattern() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCheck), userInfo: nil, repeats: false)
    }
    
    @objc func timerCheck() {
        timer?.invalidate()
        timer = nil
        if patternView.viewHor.alpha > 0 {
            patternView.hideAnimated()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        fireCheckingForPattern()
        
        centerContent()
        cropResult()
        
        print("didZoom")
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        patternView.showAnimated()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        patternView.hideAnimated()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        centerContent()
        
        cropResult()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        patternView.showAnimated()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        patternView.hideAnimated()
    }
    
    func centerContent(contentSize: CGSize? = nil) {
        let cSize = contentSize ?? scrollView.contentSize
        
        if (cSize.width == 0 || cSize.height == 0) { return }
        
        let offsetX = max((scrollView.bounds.width - cSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - cSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        
        setPattern()
    }
}
