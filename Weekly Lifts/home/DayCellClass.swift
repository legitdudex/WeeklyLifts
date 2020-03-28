//
//  DayCellClass.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/14/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import Foundation

class dayCell{
    var actualDate: String
    var dayOfTheWeek: String
    
    init(actualDate: String, dayOfTheWeek: String){
        self.actualDate = actualDate;
        self.dayOfTheWeek = dayOfTheWeek;
    }
}
