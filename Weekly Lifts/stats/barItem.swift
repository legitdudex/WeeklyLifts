//
//  File.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/19/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import Foundation

class barItem{
    var workoutName: String;
    var numberSets: Int;
    var averageRepsPerSet: Double;
    var averageWeightPerSet: Double;
    
    init(workoutName: String, numberSets: Int, averageRepsPerSet: Double, averageWeightPerSet: Double){
        self.workoutName = workoutName;
        self.numberSets = numberSets;
        self.averageRepsPerSet = averageRepsPerSet;
        self.averageWeightPerSet = averageWeightPerSet;
    }
}
