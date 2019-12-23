//
//  MainController.swift
//  LocalSearch
//
//  Created by Alexander Römer on 23.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit
import LBTATools

class MainController: UIViewController, SelectAnnotation {
    
    private let mapView               = MKMapView()
    private let cardMapItemController = CardMapItemViewController()
    private let searchTextField       = UITextField(placeholder: "Search query")
    private var anchoredConstraints     : AnchoredConstraints!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAndLayoutMapView()
        performLocalSearch()
        setupSearchUI()
        setupLocationsCarousel()
        setupKeyboardListener()

    }
    
    fileprivate func setupKeyboardListener() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = value.cgRectValue
            self.anchoredConstraints.bottom?.constant = -keyboardFrame.size.height

            UIView.animate(withDuration: 0, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.anchoredConstraints.bottom?.constant = 0
            
            UIView.animate(withDuration: 0, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)        }
    }
    
    fileprivate func setupAndLayoutMapView() {
        cardMapItemController.selectAnnotaionDelegate = self
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.fillSuperview()
    }
    
    fileprivate func setupLocationsCarousel() {
        let locationCardView = cardMapItemController.view!
        view.addSubview(locationCardView)
        anchoredConstraints = locationCardView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 100))
    }
    
    fileprivate func setupSearchUI() {
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        whiteContainer.stack(searchTextField).withMargins(.allSides(16))
        
        let _ = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { (_) in
                self.performLocalSearch()
        }
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (resp, err) in
            if let err = err {
                print("Failed local search:", err)
                return
            }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.cardMapItemController.items.removeAll()
            
            resp?.mapItems.forEach({ (mapItem) in
                print(mapItem.address())
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.cardMapItemController.items.append(mapItem)
                self.mapView.addAnnotation(annotation)
            })
            
            if resp?.mapItems.count != 0 {
                self.cardMapItemController.collectionView.scrollToItem(at: [0, 0], at: .centeredHorizontally, animated: true)
            }
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    internal func shouldSelectAnnotion(annotation: String) {
        let annotations = mapView.annotations
        annotations.forEach({ (annotationTitle) in
            if annotationTitle.title == annotation {
                mapView.selectAnnotation(annotationTitle, animated: true)
            }
        })
    }
    
}


extension MainController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        return annotationView
    }
    
}




struct MainPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        typealias UIViewControllerType = MainController
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) -> MainController {
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: UIViewControllerRepresentableContext<MainPreview.ContainerView>) {
        }
    }
}
