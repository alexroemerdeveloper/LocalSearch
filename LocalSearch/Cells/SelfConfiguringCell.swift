//
//  SelfConfiguringCell.swift
//  LocalSearch
//
//  Created by Alexander Römer on 23.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//
import Foundation
import MapKit

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with app: MKMapItem)
}
