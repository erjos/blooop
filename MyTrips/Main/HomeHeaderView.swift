//
//  HomeHeaderView.swift
//  JustGoWithIt
//
//  Created by Joseph, Ethan on 6/30/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    struct Constants {
        static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        static let minHeight: CGFloat = 44 + statusBarHeight
        static let maxHeight: CGFloat = 400.0
    }
    
    let headerbackground = UIColor.init(red: 86/255, green: 148/255, blue: 217/255, alpha: 1.0)
    
    public var image: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "city_2"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("My Trips", comment: "")
        label.textAlignment = .center
        label.textColor = .white
        label.shadowOffset = CGSize(width: 2, height: 2)
        label.shadowColor = .darkGray
        return label
    }()
    
    // 1
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        configureView()
    }
    
    // 2
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        //fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    // 3
    func configureView() {
        backgroundColor = headerbackground //.darkGray
        contentView.backgroundColor = headerbackground
        self.imageView.image = #imageLiteral(resourceName: "city_2")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        gradientView.backgroundColor = headerbackground.withAlphaComponent(0.1)
        addSubview(titleLabel)
    }
    
    // 4
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        let labelHeight = titleLabel.bounds.height
        let calcValue = bounds.height - labelHeight - Constants.statusBarHeight
        var yVal:CGFloat = 0

        if (calcValue >= 20){
            yVal = calcValue
        } else {
            yVal = Constants.statusBarHeight
        }
        
        titleLabel.frame = CGRect(
            x: 0,
            y: yVal,
            width: frame.width,
            height: labelHeight)
    }
    
    func update(withScrollPhasePercentage scrollPhasePercentage: CGFloat) {
        // 1
        let imageAlpha = min(scrollPhasePercentage.scaled(from: 0...0.8, to: 0...1), 1.0)
        imageView.alpha = imageAlpha
        // 2
        let fontSize = scrollPhasePercentage.scaled(from: 0...1, to: 20.0...60.0)
        let font = UIFont(name: "HelveticaNeue-Medium", size: fontSize)
        titleLabel.font = font
        
        if(bounds.height > Constants.minHeight){
         titleLabel.sizeToFit()
        }
    }
}


