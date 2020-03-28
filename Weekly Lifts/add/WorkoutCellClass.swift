//
//  WorkoutCellClass.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/12/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import Foundation

class workoutCell{
    var setNumber: String
    var repsNumber: String
    var weightNumber: String
    
    init(setNumber: String, repsNumber: String, weightNumber: String){
        self.setNumber = setNumber;
        self.repsNumber = repsNumber;
        self.weightNumber = weightNumber;
    }
}
