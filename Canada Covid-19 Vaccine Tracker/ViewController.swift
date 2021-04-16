//
//  ViewController.swift
//  Canada Covid-19 Vaccine Tracker
//
//  Created by Rahul Niraula on 2021-04-08.
//

import UIKit
import Charts
import TinyConstraints
import SwiftUI



class ViewController: UIViewController, SummaryManagerDelegate{
    
    @IBOutlet weak var movingAverageSwitch: UISwitch!
   
    @IBOutlet weak var maLabel: UILabel!
    
    @IBOutlet weak var provinceSelector: UIPickerView!
    
    @IBOutlet weak var graphLabel: UILabel!
    
    @IBOutlet weak var card_chartStack: UIStackView!
    
    @IBOutlet weak var firstBox: UIView!
    
    @IBOutlet weak var secondBox: UIView!
    
    @IBOutlet weak var thirdBox: UIView!
    
    @IBOutlet weak var fourthBox: UIView!
    
    @IBOutlet weak var totalVaccinations: UILabel!
    
    @IBOutlet weak var dosesDelivered: UILabel!
    
    @IBOutlet weak var perCapitaVaccinated: UILabel!
    
    @IBOutlet weak var dosesBar: UIProgressView!
    
    @IBOutlet weak var dosesText: UILabel!
    
    @IBOutlet weak var perVacBar: UIProgressView!
    
    @IBOutlet weak var stackView2: UIView!
    
    var summaryManager = SummaryManager()
    
    var datesData : [String] = []
    
    let provinces = ["Canada", "BC", "AB", "SK","MB","ON","QC","NB","NS","PE","NL","NU"]
    
    var cur_por : Int = 0
    
    
    @IBAction func switchchanged(_ sender: UISwitch) {
        print(provinces[cur_por])
        summaryManager.fetchSummary(provinces[cur_por])
    }
    
    lazy var lineChartView : LineChartView = {
        let chartView = LineChartView()
        
        chartView.layer.cornerRadius = CGFloat(10)
        stackView2.clipsToBounds = true
        stackView2.layer.cornerRadius = CGFloat(10)
        chartView.backgroundColor = UIColor(red: 0.15, green: 0.40, blue: 0.47, alpha: 1.00)
        
        chartView.rightAxis.enabled = false
        chartView.animate(xAxisDuration: 2.5)
        chartView.xAxis.labelCount = 5
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.drawGridLinesEnabled = false
    
        
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        
        chartView.legend.enabled = false
        
        
        chartView.leftAxis.labelTextColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        chartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.leftAxis.axisMinimum = 0

        return chartView
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        movingAverageSwitch.backgroundColor = .white
        
        movingAverageSwitch.layer.cornerRadius = 16.0
        
        initializeGraph()

        let boxes = [firstBox, secondBox, thirdBox, fourthBox]
        
        summaryManager.delegate = self
       
        summaryManager.fetchSummary("Canada")
        lineChartView.delegate = self
        provinceSelector.delegate=self
        provinceSelector.dataSource = self
        
        for box in boxes{
            box!.layer.cornerRadius = CGFloat(10)
        }
        stackView2.clipsToBounds = true
        stackView2.layer.cornerRadius = CGFloat(10)
        
        graphLabel.showsLargeContentViewer = false
        
        
        
    
    }
    
    func initializeGraph(){
        
        stackView2.addSubview(lineChartView)
        lineChartView.bottomToSuperview(.none, offset: -50, relation: .equalOrGreater, priority: .defaultLow, isActive: true, usingSafeArea: true)
        lineChartView.width(to: stackView2)
        lineChartView.height(to: stackView2, .none, multiplier: 1, offset: -65, relation: .equal, priority: .defaultHigh, isActive: true)
        lineChartView.layer.zPosition = -1
        
        
        movingAverageSwitch.bottom(to: stackView2, .none, offset: -15, relation: .equalOrGreater, priority: .defaultHigh, isActive: true)
        
        movingAverageSwitch.right(to: stackView2, .none, offset: -10, relation: .equalOrGreater, priority: .defaultHigh, isActive: true)
        
        maLabel.bottom(to: stackView2, .none, offset: -25, relation: .equalOrGreater, priority: .defaultHigh, isActive: true)
        
        maLabel.right(to: stackView2, .none, offset: -70, relation: .equalOrGreater, priority: .defaultHigh, isActive: true)
        
        
        
    }
    
    func didUpdateData(_ givenData : SummaryData){
        
        DispatchQueue.main.async {
            
            let texts = self.summaryManager.getNumbers(givenData, province: self.provinces[Int(self.provinceSelector.selectedRow(inComponent: 0).description)!])
            
            
            self.totalVaccinations.text = texts[0]
            self.dosesDelivered.text = texts[1]
            self.perCapitaVaccinated.text = texts[2]
            self.dosesBar.progress = Float(texts[3])!
            self.dosesText.text = texts[4] + "% delivered doses adminstered"
            self.perVacBar.progress = Float(texts[5])!/100
            
            let moving = self.movingAverageSwitch.isOn
            
            self.lineChartView.data = self.summaryManager.fillGraph(givenData, moving: moving)
            
            self.datesData = []
                
            self.datesData = self.summaryManager.fillGraphXaxis(givenData)
            
            self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.datesData)
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            self.graphLabel.text = numberFormatter.string(from: NSNumber(value: Int(givenData.data.last!.changeVaccinations ?? 0)))! + " doses administered today."
            
            self.animateGraph()
            
            
        }
    }
    
    
    func animateGraph(){
        
        self.lineChartView.animate(xAxisDuration: 1)
        
    }
    
    
    
     

    
}



extension ViewController: ChartViewDelegate{
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let date : NSMutableString
        date = NSMutableString(string: datesData[Int(entry.x)])
        date.insert(" ", at: 3)
        let value = entry.y
        
        chartView.highlightPerTapEnabled = true
        
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        graphLabel.text = numberFormatter.string(from: NSNumber(value: value))! + " doses administered on " + String(date) + "."
        
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        graphLabel.text = "Doses administered per day"
    }
    
}


extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        
        return provinces[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cur_por = row
        summaryManager.fetchSummary(provinces[row])
    }
    
}
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return provinces.count
        
    }
    
}



