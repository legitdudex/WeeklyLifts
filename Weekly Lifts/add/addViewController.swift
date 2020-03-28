//
//  ThirdViewController.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/12/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit
import Foundation

class addViewController: UIViewController {

    var workoutCells: [(workout: String, workoutArray: [workoutCell])] = [];
    var blurEffect: UIVisualEffect!;
    

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var ourTableView: UITableView!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var workoutNameTextField: UITextField!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var setNumberTextField: UITextField!
    @IBOutlet weak var repsNumberLabel: UILabel!
    @IBOutlet weak var repsNumberTextField: UITextField!
    @IBOutlet weak var weightNumberLabel: UILabel!
    @IBOutlet weak var weightNumberTextField: UITextField!
    @IBOutlet var modalPopUpView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addNewSetButton: UIBarButtonItem!
    @IBOutlet weak var modalDoneButton: UIButton!
    @IBOutlet var errorModalView: UIView!
    @IBOutlet weak var errorModalLabel: UILabel!
    @IBOutlet weak var errorModalButton: UIButton!
    
    override func viewDidLoad() {
        updateTableData();
        modalPopUpView.isHidden = true;
        modalPopUpView.backgroundColor = .gray;
        
        blurEffect = blurView.effect;
        blurView.effect = nil;
        workoutNameLabel.text = "Exercise Name:";
        setNumberLabel.text = "Set #:";
        repsNumberLabel.text = "# of Reps:";
        weightNumberLabel.text = "lb:";
        modalDoneButton.setTitle("Done", for: .normal);
        modalDoneButton.backgroundColor = .black
        modalDoneButton.tintColor = .white;
        errorModalView.isHidden = true;
        errorModalView.backgroundColor = .gray;
        
        errorModalLabel.text = "Error: Please fill all fields!";
        errorModalButton.setTitle("Ok", for: .normal)
        errorModalButton.backgroundColor = .black
        errorModalButton.tintColor = .white
        saveButton.title = "Save";
        addNewSetButton.title = "+";
    }
    
    func postDataToDatabase(){
        for entry in workoutCells{
            for workout in entry.workoutArray{
                let ourDateFormatter = DateFormatter();
                ourDateFormatter.dateFormat = "yyyy-MM-dd"
                ourDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                var ourDate = ourDateFormatter.string(from: Date());
                let workoutDateHighDayIndex = ourDate.index(ourDate.endIndex, offsetBy: -2);
                let workoutDateHighPref = ourDate.prefix(8);
                var endingDay = Int(ourDate[workoutDateHighDayIndex...]);
                endingDay = endingDay! + 1;
                ourDate = workoutDateHighPref+String(describing: endingDay!);
                let url = URL(string: "http://localhost:8080/workoutTrackerServer/workoutTrackerServer")!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let parameters: [String: Any] = [
                    "deviceID": "id1",
                    "workoutDate": ourDate,
                    "workoutName": entry.workout,
                    "setNumber": workout.setNumber,
                    "reps": workout.repsNumber,
                    "weight": workout.weightNumber
                ]
                request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                            print("error", error ?? "Unknown error")
                            return
                    }
            
                    guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                        print("statusCode should be 2xx, but is \(response.statusCode)")
                        print("response = \(response)")
                        return
                    }
            
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                    self.workoutCells = [];
                    self.updateTableData();
                }
        
                task.resume()
            }
        }
    }
    
   
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        postDataToDatabase();
        
        
    }
    @IBAction func addNewSetButtonTouched(_ sender: Any) {
        //show modal
        //show blur effect in background
        modalPopUpView.isHidden = false;
        self.view.addSubview(modalPopUpView);
        modalPopUpView.center = self.view.center;
        modalPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3);
        modalPopUpView.alpha = 0;
        UIView.animate(withDuration: 0.5){
            self.blurView.effect = self.blurEffect;
            self.modalPopUpView.alpha = 1;
            self.modalPopUpView.transform = CGAffineTransform.identity;
        }
    }
    @IBAction func modalDoneButtonTouched(_ sender: Any) {
        //hide modal
        //clear modal text fields
        //hide blur effect
        //add workout set to table
        let workoutName: String = workoutNameTextField.text ?? "";
        let setNumber: String = setNumberTextField.text ?? "";
        let repsNumber: String = repsNumberTextField.text ?? "";
        let weightNumber: String = weightNumberTextField.text ?? "";
        
        if(workoutName == "" || setNumber == "" || repsNumber == "" || weightNumber == ""){
            modalPopUpView.isHidden = true;
            errorModalView.isHidden = false;
            self.view.addSubview(errorModalView);
            errorModalView.center = self.view.center;
            errorModalView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3);
            errorModalView.alpha = 1;
        }
        else{
            workoutNameTextField.text = "";
            setNumberTextField.text = "";
            repsNumberTextField.text = "";
            weightNumberTextField.text = "";
            addWorkoutCell(name: workoutName, set: setNumber, reps: repsNumber, weight: weightNumber);
            self.updateTableData();
            UIView.animate(withDuration: 0.5){
                self.modalPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3);
                self.modalPopUpView.alpha = 0;
                self.modalPopUpView.removeFromSuperview();
                self.blurView.effect = nil;
            }
            modalPopUpView.isHidden = true;
        }
    }
    @IBAction func errorModalButtonClose(_ sender: Any) {
        errorModalView.isHidden = true;
        modalPopUpView.isHidden = false;
        self.errorModalView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3);
        self.errorModalView.alpha = 0;
        self.errorModalView.removeFromSuperview();
    }
    
    func addWorkoutCell(name: String, set: String, reps: String, weight: String){
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
        if(workoutCells.count == 0){
            let workoutArray: [workoutCell] = [];
            workoutCells.append((workout: nameStringify, workoutArray: workoutArray));
            workoutCells[0].workoutArray.append(cell);
        }
        else{
            var added: Bool = false;
            for index in 0...workoutCells.count - 1{
                if(workoutCells[index].workout == nameStringify){
                    added = true;
                    workoutCells[index].workoutArray.append(cell);
                }
            }
            if(added == false){
                let workoutArray: [workoutCell] = [];
                workoutCells.append((workout: nameStringify, workoutArray: workoutArray));
                workoutCells[workoutCells.count - 1].workoutArray.append(cell);
            }
        }
    } //end addWorkoutCell
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension addViewController: UITableViewDelegate, UITableViewDataSource{
    func updateTableData(){
        self.ourTableView.delegate = self;
        self.ourTableView.dataSource = self;
        ourTableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel();
        label.backgroundColor = .yellow;
        label.text = workoutCells[section].workout;
        return label;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutCells[section].workoutArray.count + 1;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(workoutCells.count == 0){ tableView.isHidden = true; }
        else{ tableView.isHidden = false; }
        return workoutCells.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return workoutCells[section].workout;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 45.0;
        }
        else{ return 90.0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWorkoutCell", for: indexPath) as! WorkoutCell;
        if(indexPath.row == 0){
            cell.setNumber.text = "Set";
            cell.repsNumber.text = "Reps";
            cell.weightNumber.text = "lb";
        }
        else{
            let workoutCell = workoutCells[indexPath.section].workoutArray[indexPath.row - 1];
            cell.repsNumber.text = workoutCell.repsNumber;
            cell.setNumber.text = workoutCell.setNumber;
            cell.weightNumber.text = workoutCell.weightNumber;
        }
        return cell;
    }
    
    
}
