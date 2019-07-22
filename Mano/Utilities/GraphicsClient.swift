//
//  GraphicsClient.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import UIKit

class GraphicsClient {
    func segmentedControlBar(titles: [String],numberOfSegments: Int) -> UISegmentedControl{
        let segmentedControl = UISegmentedControl()
        var segments = numberOfSegments - 1
        while segments >= 0{
            segmentedControl.insertSegment(withTitle: titles[segments], at: segments, animated: true)
            segments -= 1
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        segmentedControl.tintColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Arial Rounded MT Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Arial Rounded MT Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
        
        
        return segmentedControl
    }
    
    lazy var animatedView: UIView = {
        var view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        return view
    }()
    
    lazy var animatedViewRail: UIView = {
        var view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        return view
    }()
    
    func setupAnimatedView(view: UIView,animatedView: UIView, customSegmentedBar: UISegmentedControl,numberOfSegments: Int){
        view.addSubview(animatedView)
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.topAnchor.constraint(equalTo: customSegmentedBar.bottomAnchor).isActive = true
        animatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animatedView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        animatedView.widthAnchor.constraint(equalToConstant: view.frame.width / CGFloat(numberOfSegments)).isActive = true
        
    }
    func setupAnimatedViewRail(view: UIView, animatedViewRail: UIView, customSegmentedBar: UISegmentedControl){
        view.addSubview(animatedViewRail)
        animatedViewRail.translatesAutoresizingMaskIntoConstraints = false
        animatedViewRail.topAnchor.constraint(equalTo: customSegmentedBar.bottomAnchor).isActive = true
        animatedViewRail.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animatedViewRail.heightAnchor.constraint(equalToConstant: 5).isActive = true
        animatedViewRail.widthAnchor.constraint(equalTo: customSegmentedBar.widthAnchor).isActive = true
    }
    
}
