//
//  FilterView.swift
//  Mano
//
//  Created by Leandro Wauters on 8/1/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: AnyObject {
    func newViewTapped()
    func thisWeekTapped()
    func tomorrowTapped()
    func otherTapped()
}
class FilterView: UIView {

    var delegate: FilterViewDelegate!
    @IBOutlet weak var newButton: UIButton!
    
    
    @IBAction func NewButtonPressed(_ sender: Any) {
        delegate.newViewTapped()
    }
    @IBAction func thisWeekPressed(_ sender: Any) {
        delegate.thisWeekTapped()
    }
    
    @IBAction func tomorrowPressed(_ sender: Any) {
        delegate.tomorrowTapped()
    }
    
    
    @IBAction func otherPressed(_ sender: Any) {
        delegate.otherTapped()
    }
    
}
