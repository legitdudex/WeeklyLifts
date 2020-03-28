//
//  DisplayDayViewController.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/14/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit

class DisplayDayViewController: UIViewController {
    var dayWorkoutCells: [(workout: String, workoutArray: [workoutCell])] = [];
    //we need to get the data from our server
    
    @IBOutlet weak var workoutDayTableView: UITableView!
    var convertedJsonArray: [[String: AnyObject]]?;
    var actualDate: String?;
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTableData();
    }
    
    func convertJsonToArrayOfObject(){
        for entry in convertedJsonArray!{
            //print(entry)
            let date = String(describing: entry["workoutDate"]!);
            if(actualDate == date){
                addWorkoutDayCell(name: String(describing: entry["workoutName"]!), set: String(describing: entry["setNumber"]!), reps: String(describing: entry["repsNumber"]!), weight: String(describing: entry["weightNumber"]!));
            }
        }
    }
    
    func addWorkoutDayCell(name: String, set: String, reps: String, weight: String){
        //first, make sure to get rid of all white spaces//
        //then, make sure first letter of name is capitalized//
        var nameStringify: String = name.trimmingCharacters(in: .whitespacesAndNewlines);
        let setStringify: String = set.trimmingCharacters(in: .whitespacesAndNewlines);
        let repsStringify: String = reps.trimmingCharacters(in: .whitespacesAndNewlines);
        let weightStringify: String = weight.trimmingCharacters(in: .whitespacesAndNewlines);
        //now we have got rid of all the potential leading and trailing whitespaces in the parameters that might interfere with our add method//
        let nameComponents = name.components(separatedBy: "");
        nameStringify = "";
        for component in nameComponents{
            nameStringify += component.capitalized;
        }
        
        
        let cell = workoutCell(setNumber: setStringify, repsNumber: repsStringify, weightNumber: weightStringify);
        if(dayWorkoutCells.count == 0){
            let workoutArray: [workoutCell] = [];
            dayWorkoutCells.append((workout: nameStringify, workoutArray: workoutArray));
            dayWorkoutCells[0].workoutArray.append(cell);
        }
        else{
            var added: Bool = false;
            for index in 0...dayWorkoutCells.count - 1{
                if(dayWorkoutCells[index].workout == nameStringify){
                    added = true;
                    dayWorkoutCells[index].workoutArray.append(cell);
                }
            }
            if(added == false){
                let workoutArray: [workoutCell] = [];
                dayWorkoutCells.append((workout: nameStringify, workoutArray: workoutArray));
                dayWorkoutCells[dayWorkoutCells.count - 1].workoutArray.append(cell);
            }
        }
    } //end addWorkoutCell
}

extension DisplayDayViewController: UITableViewDelegate, UITableViewDataSource{
    func updateTableData(){
        self.workoutDayTableView.delegate = self;
        self.workoutDayTableView.dataSource = self;
        convertJsonToArrayOfObject()
        workoutDayTableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 45.0;
        }
        else{ return 90.0; }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel();
        label.backgroundColor = .yellow;
        label.text = dayWorkoutCells[section].workout;
        return label;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayWorkoutCells[section].workout;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayWorkoutCells[section].workoutArray.count + 1;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(dayWorkoutCells.count == 0){ workoutDayTableView.isHidden = true; }
        else{ workoutDayTableView.isHidden = false; }
        return dayWorkoutCells.count;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWorkoutCell", for: indexPath) as! DisplayDayTableViewCell;
        if(indexPath.row == 0){
            cell.setNumber.text = "Set";
            cell.repsNumber.text = "Reps";
            cell.weightNumber.text = "lb";
        }
        else{
            let workoutCell = dayWorkoutCells[indexPath.section].workoutArray[indexPath.row - 1];
            cell.repsNumber.text = workoutCell.repsNumber;
            cell.setNumber.text = workoutCell.setNumber;
            cell.weightNumber.text = workoutCell.weightNumber;
        }
        return cell;
    }
    
    
}
