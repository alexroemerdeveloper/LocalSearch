//
//  CardMapItemCell.swift
//  LocalSearch
//
//  Created by Alexander Römer on 23.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import UIKit
import MapKit

class CardMapItemCell: UICollectionViewCell, SelfConfiguringCell {

    static let reuseIdentifier: String = "CardMapItemCell"
    private let label        = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    private let addressLabel = UILabel(text: "Address", numberOfLines: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layout() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius  = 5
        blurView.layer.masksToBounds = true
        addSubview(blurView)
        blurView.fillSuperview()
        label.textColor = .white
        addressLabel.textColor = .white
        hstack(stack(label, addressLabel, spacing: 12).withMargins(.allSides(16)),
               alignment: .center)
    }

    internal func configure(with app: MKMapItem) {
        self.label.text = app.name
        self.addressLabel.text = app.address()
    }

}
