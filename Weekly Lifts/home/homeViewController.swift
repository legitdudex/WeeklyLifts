//
//  SecondViewController.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/11/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {
    @IBOutlet weak var weekTableView: UITableView!
    var deviceID: String = "id1";
    
    var workoutDays: [dayCell] = []; //store relevant days of the week here
    var sendingDay: dayCell?;
    var convertedJsonArray: [[String: AnyObject]]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Date());
        let dateformat = DateFormatter();
        dateformat.dateFormat = "yyyy-MM-dd";
        print(dateformat.string(from: Date()));
        getDataFromDataBase()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        workoutDays.removeAll()
        convertedJsonArray?.removeAll()
        updateWeekData()
        viewDidLoad()
    }
    
    func getSundayOfCurrentWeek(currentDay: Date) -> String{
        let ourCalendar = Calendar.init(identifier: .gregorian)
        var comps = ourCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDay);
        comps.weekday = 1;
        let returningDate =  ourCalendar.date(from: comps)!;
        let ourDateFormatter = DateFormatter();
        ourDateFormatter.dateFormat = "yyyy-MM-dd"
        return ourDateFormatter.string(from: returningDate);
    }
    func getSaturdayOfCurrentWeek(currentDay: Date) -> String{
        let ourCalendar = Calendar.init(identifier: .gregorian)
        var comps = ourCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDay);
        comps.weekday = 7;
        let returningDate = ourCalendar.date(from: comps)!;
        let ourDateFormatter = DateFormatter();
        ourDateFormatter.dateFormat = "yyyy-MM-dd";
        return ourDateFormatter.string(from: returningDate);
    }
    
    
    func getDataFromDataBase(){
        var workoutDateLow: String = getSundayOfCurrentWeek(currentDay: Date());
        var workoutDateHigh: String = getSaturdayOfCurrentWeek(currentDay: Date());
        let workoutDateHighDayIndex = workoutDateHigh.index(workoutDateHigh.endIndex, offsetBy: -2);
        let workoutDateHighPref = workoutDateHigh.prefix(8);
        var endingDay = Int(workoutDateHigh[workoutDateHighDayIndex...]);
        endingDay = endingDay! + 1;
        workoutDateHigh = workoutDateHighPref+String(describing: endingDay!);
        let workoutDateLowDayIndex = workoutDateLow.index(workoutDateLow.endIndex, offsetBy: -2);
        let workoutDateLowPref = workoutDateLow.prefix(8);
        var endingDayLow = Int(workoutDateLow[workoutDateLowDayIndex...]);
        endingDayLow = endingDayLow! + 1;
        workoutDateLow = workoutDateLowPref+String(describing: endingDayLow!);
        print(workoutDateLow)
        print(workoutDateHigh)
        let scriptURL = "http://localhost:8080/workoutTrackerServer/workoutTrackerServer?deviceID=\(deviceID)&workoutDateLow=\(workoutDateLow)&workoutDateHigh=\(workoutDateHigh)";
        let myurl = NSURL(string: scriptURL);
        let request = NSMutableURLRequest(url:myurl! as URL);
        request.httpMethod = "GET";
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: AnyObject]]{
                    self.convertedJsonArray = convertedJsonIntoDict;
                    var dateArray: [String] = [];
                    for entry in self.convertedJsonArray!{
                        if(!dateArray.contains(String(describing: entry["workoutDate"]!))){
                            dateArray.append(String(describing: entry["workoutDate"]!));
                        }
                    }
                    var count = 0;
                    for entry in dateArray{
                        let index = entry.index(entry.endIndex, offsetBy: -2);
                        var day = Int(entry[index...])!;
                        let sunday = Int(self.getSundayOfCurrentWeek(currentDay: Date())[index...]);
                        if(day == sunday){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Sunday"));
                        }
                        else if(day == sunday! + 1){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Monday"));
                        }
                        else if(day == sunday! + 2){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Tuesday"));
                        }
                        else if(day == sunday! + 3){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Wednesday"));
                        }
                        else if(day == sunday! + 4){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Thursday"));
                        }
                        else if(day == sunday! + 5){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Friday"));
                        }
                        else if(day == sunday! + 6){
                            self.workoutDays.append(dayCell(actualDate: entry, dayOfTheWeek: "Saturday"));
                        }
                        count = count + 1;
                    }
                    self.updateWeekData();
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }
    
}



extension homeViewController: UITableViewDelegate, UITableViewDataSource{
    func updateWeekData(){
        DispatchQueue.main.async {
            self.weekTableView.delegate = self;
            self.weekTableView.dataSource = self;
            self.weekTableView.reloadData();
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutDays.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weekTableView.dequeueReusableCell(withIdentifier: "weekCell", for: indexPath) as! DayCell;
        cell.actualDate.text = workoutDays[indexPath.row].actualDate;
        cell.dayLabel.text = workoutDays[indexPath.row].dayOfTheWeek
        return cell;
    }
    
    //prepare for segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actualDate = workoutDays[indexPath.row].actualDate;
        print(actualDate);
        let storyboard = UIStoryboard(name:
            "Main", bundle: nil);
        let dayCellView = storyboard.instantiateViewController(withIdentifier: "DisplayDayViewController") as! DisplayDayViewController;
        dayCellView.convertedJsonArray = self.convertedJsonArray;
        dayCellView.actualDate = actualDate;
        self.navigationController?.pushViewController(dayCellView, animated: true);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
   
}
