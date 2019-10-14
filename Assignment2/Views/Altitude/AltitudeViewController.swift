//
//  AltitudeViewController.swift
//  Assignment2
//
//  Created by M Rahman on 24/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit
import Charts

class AltitudeViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var avg24hoursLabel: UILabel!
    @IBOutlet weak var avg3daysLabel: UILabel!
    
    @IBOutlet weak var avg24hours: UILabel!
    @IBOutlet weak var avg3days: UILabel!
    @IBOutlet weak var currentReading: UILabel!
    var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentLabel.text = "NA"
        avg24hoursLabel.text = "NA"
        avg3daysLabel.text = "NA"
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return Theme.current.barStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Data.currentReading.id != "" {
            setFields()
            updateGraph()
        }
        observer = NotificationCenter.default.addObserver(forName: .currentReadingUpdate, object: nil, queue: OperationQueue.main) { (notification) in
            self.setFields()
            self.updateGraph()
            self.chartView.data?.notifyDataChanged()
            self.chartView.notifyDataSetChanged()
        }
    }
    
    func setFields(){
        currentLabel.text = "\(Data.currentReading.altitude) m"
        let average = Data.get3days(sensor: "Altitude")
        avg24hoursLabel.text = (average[0] == "NA" ? "NA" : "\(average[0]) m")
        avg3daysLabel.text = (average[1] == "NA" ? "NA" : "\(average[1]) m")
        currentLabel.textColor = Theme.current.text
        avg24hoursLabel.textColor = Theme.current.text
        avg3daysLabel.textColor = Theme.current.text
        currentReading.textColor = Theme.current.text
        avg3days.textColor = Theme.current.text
        avg24hours.textColor = Theme.current.text
        self.view.backgroundColor = Theme.current.primary
    }
    
    func updateGraph(){
        chartView.legend.enabled = false
        var lineChartData = [ChartDataEntry]()
        
        var number = 10
        let count = Data.sensorReadings.count
        if count < number {
            number = count
        }
        for i in (count - number)..<count{
            let value = ChartDataEntry(x: Double(i), y: Data.sensorReadings[i].altitude)
            lineChartData.append(value)
        }
        let line = LineChartDataSet(entries: lineChartData, label: "")
        line.colors = [Theme.current.text]
        let data = LineChartData()
        data.addDataSet(line)
        chartView.data = data
        chartView.chartDescription?.text = "Altitude Chart"
        //Changing color
        chartView.data?.setValueTextColor(Theme.current.text)
        chartView.xAxis.labelTextColor = Theme.current.text
        chartView.leftAxis.labelTextColor = Theme.current.text
        chartView.rightAxis.labelTextColor = Theme.current.text
        chartView.chartDescription?.textColor = Theme.current.text
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
