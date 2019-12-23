//
//  CardMapItemViewController.swift
//  LocalSearch
//
//  Created by Alexander Römer on 23.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//
import UIKit
import MapKit

enum Section: CaseIterable {
    case main
}

protocol SelectAnnotation: class {
    func shouldSelectAnnotion(annotation: String)
}

class CardMapItemViewController: UIViewController, UICollectionViewDelegate {
    
    public var items                = [MKMapItem]() {
        didSet  {
            createSnapshot(from: items)
        }
    }
    
    internal var collectionView      : UICollectionView!
    private var dataSource           : UICollectionViewDiffableDataSource<Section, MKMapItem>?
    internal weak var selectAnnotaionDelegate: SelectAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewLayout()
        createDataSource()
    }
    
    fileprivate func collectionViewLayout() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor  = .clear
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.register(CardMapItemCell.self, forCellWithReuseIdentifier: CardMapItemCell.reuseIdentifier)
    }
    
    fileprivate func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with app: MKMapItem, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)") }
        cell.configure(with: app)
        return cell
    }
    
    fileprivate func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MKMapItem>(collectionView: collectionView) { collectionView, indexPath, mapItem in
            return self.configure(CardMapItemCell.self, with: mapItem, for: indexPath)
        }
    }
    
    fileprivate func createSnapshot(from pins: [MKMapItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MKMapItem>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(pins)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            return self.createFeaturedSection()
        }
        return layout
    }
    
    fileprivate func createFeaturedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .fractionalHeight(1))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        return layoutSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAnnotaionDelegate?.shouldSelectAnnotion(annotation: self.items[indexPath.item].name ?? "")
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }


}

