//
//  FirstViewController.swift
//  Weekly Lifts
//
//  Created by Kang-hee cho on 5/11/19.
//  Copyright © 2019 Kang-hee Cho. All rights reserved.
//

import UIKit;
import Charts;
class statsViewController: UIViewController, ChartViewDelegate {

    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var statsLabel: UILabel!
    var convertedJsonArray: [[String: AnyObject]]?;
    var entries: [String: [String: Int]] = [String: [String: Int]]();
    var deviceID: String = "id1"
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self;
        statsLabel.text = "Statistics For This Week"
        statsLabel.textColor = .blue
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        entries.removeAll();
        self.getDataForThisWeek();
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
    
    func getDataForThisWeek(){
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
                    for entry in self.convertedJsonArray!{
                        print(entry);
                        let workoutName: String = String(describing: entry["workoutName"]!);
                        let setNumber = String(describing: entry["setNumber"]!);
                        let repsNumber = String(describing: entry["repsNumber"]!);
                        let weightNumber = String(describing: entry["weightNumber"]!);
                        if(self.entries.keys.contains(workoutName)){
                            self.entries[workoutName]!["totalSets"] = self.entries[workoutName]!["totalSets"]! + Int(setNumber)!;
                            self.entries[workoutName]!["totalReps"] = self.entries[workoutName]!["totalReps"]! + Int(repsNumber)!;
                            self.entries[workoutName]!["totalWeight"] = self.entries[workoutName]!["totalWeight"]! + Int(weightNumber)!;
                        }
                        else{
                            self.entries[workoutName] = [String: Int]();
                            self.entries[workoutName]?["totalSets"] = Int(setNumber);
                            self.entries[workoutName]?["totalReps"] = Int(repsNumber);
                            self.entries[workoutName]?["totalWeight"] = Int(weightNumber);
                        }
                    }
                    self.updateGraph()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func updateGraph(){
        var counter = 0;
        var dataEntries: [String: [BarChartDataEntry]] = [String: [BarChartDataEntry]]();
        print(entries);
        for entry in entries{
            dataEntries[entry.key] = [BarChartDataEntry]();
            dataEntries[entry.key]?.append(BarChartDataEntry(x: Double(counter), y: Double(entry.value["totalReps"]!/entry.value["totalSets"]!), data: "Avg Reps Per Set"));
            counter = counter + 1;
            dataEntries[entry.key]?.append(BarChartDataEntry(x: Double(counter), y: Double(entry.value["totalSets"]!), data: "Total Sets"));
            counter = counter + 1;
            dataEntries[entry.key]?.append(BarChartDataEntry(x: Double(counter), y: Double(entry.value["totalWeight"]!/entry.value["totalReps"]!), data: "Avg Weight Per Set"))
            counter = counter + 1;
        }
        var dataSets: [BarChartDataSet] = [BarChartDataSet]();
        for entry in dataEntries{
            dataSets.append(BarChartDataSet(entries: entry.value, label: entry.key));
        }
        let chartData = BarChartData();
        for entry in dataSets{
            entry.colors = ChartColorTemplates.joyful();
            chartData.addDataSet(entry);
        }
        chartData.setDrawValues(false);
        barChart.data = chartData;
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
}

