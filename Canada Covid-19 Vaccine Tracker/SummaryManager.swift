//
//  SummaryManager.swift
//  Canada Covid-19 Vaccine Tracker
//
//  Created by Rahul Niraula on 2021-04-08.
//

import Foundation

import Charts

protocol SummaryManagerDelegate {
    func didUpdateData(_ givenData : SummaryData)
}

struct SummaryManager{
    
    var delegate : SummaryManagerDelegate?
    
    var perCaseData : [String : Int]?
    
    let baseURL = "https://api.covid19tracker.ca/"
    
    func fetchSummary(_ endString : String){
        var urlString : String = ""
        if (endString == "Canada"){
            urlString = baseURL + "reports/#"
        }else{
            let lowercase = endString.lowercased()
            urlString = baseURL + "reports/province/" + lowercase
        }
        performRequest(urlString)
    }
    
    func performRequest(_ urlString : String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){ data, response, error  in
                if (error != nil){
                    print(error!)
                    return
                }
                
                if let safeData = data{
                    let summaryRet = self.parseJSON(safeData)!
                    delegate?.didUpdateData(summaryRet)
                }
            }
            
            task.resume()
        }
        
    }
    
    func parseJSON(_ receivedData : Data) -> SummaryData?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(SummaryData.self, from: receivedData)
            return decodedData
            
        } catch {
            
            print(error)
            return nil
        }
    }
    
    func getNumbers(_ givenData : SummaryData, province: String, one: Bool) -> [String]{
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let latestTotalVaccination = givenData.data.last?.totalVaccinations ?? 0
        let latestVaccinesDistributed = givenData.data.last?.totalVaccinesDistributed ?? 0
        let latestTotalVaccinated = givenData.data.last?.totalVaccinated ?? 0
        
        let pop_data = [
            "Canada":38000000.00,
            "QC":8575779.00,
            "ON":14733119.00,
            "NS":979115.00,
            "NB":781315.00,
            "MB":1379584.00,
            "BC":5145851.00,
            "PE":159713.00,
            "SK":1177884.00,
            "AB":4428112.00,
            "NL":520998.00,
            "NT":45074.00,
            "YT":42176.00,
            "NU":39285.00,
        ]
        
        
        
        let dosesAdm = numberFormatter.string(from: NSNumber(value: latestTotalVaccination))! + " doses administered"
        
        let dosesDel = numberFormatter.string(from: NSNumber(value: latestVaccinesDistributed))! + " doses delivered"
        
        
        var perVac = (Float(latestTotalVaccination - latestTotalVaccinated) / Float(pop_data[province]!))*100
        
        var oneDos = String(format: "%.2f", perVac ) + "% received atleast one dose"
        
        
        
        if(!one){
            perVac = (Float(latestTotalVaccinated)/Float(pop_data[province]!))*100
            
            oneDos = String(format: "%.2f", perVac ) + "% are fully vaccinated"
        }
        
        print(latestTotalVaccinated)
        
        
        let barDos = String(Float(latestTotalVaccination)/Float(latestVaccinesDistributed))
        
        let perDos = String(format: "%.2f", Float(barDos)!*100)
        
        let perVAc = String(perVac)
        
        
        
        return [dosesAdm, dosesDel, oneDos, barDos, perDos, perVAc]
    }
    
    func fillGraph(_ givenData: SummaryData, moving: Bool) -> LineChartData {
        
        var returnData : [ChartDataEntry] = []
        var count = 0
        var first_vaccine = false
        
        for data in givenData.data{
            
            _ = data.Date
            let change = data.changeVaccinations ?? 0
            
            
            if(change != 0 || first_vaccine) {
                first_vaccine = true
                let a = ChartDataEntry(x: Double(count), y: Double(change))
                returnData.append(a)
                count = count + 1
            }
    
        }
        
        
        
        var setData : LineChartDataSet
        
        
        if(moving == true){
            
            var i = 0
            var movingAverage : [ChartDataEntry] = []
            
            while (i < returnData.count) {
                
                
                if(i > 6){
                    
                let diu = (returnData[i].y + returnData[i-1].y+returnData[i-2].y+returnData[i-3].y+returnData[i-4].y+returnData[i-5].y+returnData[i-6].y)/7.0
                
                movingAverage.append(ChartDataEntry(x: returnData[i].x,
                                                  y: Double(Int(diu))))
                }
                else{
                movingAverage.append(ChartDataEntry(x: returnData[i].x,
                                                      y: (returnData[i].y)))
                }
                
                i = i + 1
            }
            
            setData = LineChartDataSet(entries: movingAverage)
            
        }else{
            setData = LineChartDataSet(entries: returnData)
        }
        
        //setData.drawCircleHoleEnabled = false
        setData.drawCirclesEnabled = false
        setData.highlightEnabled = true
        setData.mode = .cubicBezier
        setData.drawValuesEnabled = false
        setData.lineWidth = 2
        setData.fill = Fill(color: UIColor(red: 0.63, green: 0.91, blue: 0.99, alpha: 0.9))
        setData.fillAlpha = 1
        setData.drawFilledEnabled = false
        setData.drawHorizontalHighlightIndicatorEnabled = false
        setData.label = "Doses administered per day"
        setData.drawVerticalHighlightIndicatorEnabled = true
    
        
        
        let lcdData = LineChartData(dataSet: setData)
        
        return lcdData
        
        
    }
    
    func fillGraphXaxis(_ givenData: SummaryData) -> [String]{
        var stringRet : [String] = []
        var firstVaccine = false
        
        for data in givenData.data{
            let date = data.Date
            let change = data.changeVaccinations ?? 0
            
            
            if(change != 0 || firstVaccine) {
                firstVaccine = true
                var month : String = "N/A"
                var day : String = "N/A"
                
                let sixthChar = Array(date)[5]
                let seventhChar = Array(date)[6]
                
                if( sixthChar == "0" && seventhChar == "1"){
                    month = "Jan"
                }
                else if( sixthChar == "0" && seventhChar == "2"){
                    month = "Feb"
                }else if( sixthChar == "0" && seventhChar == "3"){
                    month = "Mar"
                }else if( sixthChar == "0" && seventhChar == "4"){
                    month = "Apr"
                }else if( sixthChar == "0" && seventhChar == "5"){
                    month = "May"
                }else if( sixthChar == "0" && seventhChar == "6"){
                    month = "Jun"
                }else if( sixthChar == "0" && seventhChar == "7"){
                    month = "Jul"
                }else if( sixthChar == "0" && seventhChar == "8"){
                    month = "Aug"
                }else if( sixthChar == "0" && seventhChar == "9"){
                    month = "Sep"
                }else if( sixthChar == "1" && seventhChar == "0"){
                    month = "Oct"
                }else if( sixthChar == "1" && seventhChar == "1"){
                    month = "Nov"
                }else if( sixthChar == "1" && seventhChar == "2"){
                    month = "Dec"
                }
                
                let ninthChar = Array(date)[8]
                let tenthChar = Array(date)[9]
                
                day = ""
                day.append(ninthChar)
                day.append(tenthChar)
           
                stringRet.append(month+day)
            }
        }
        
        return stringRet
    }
    
    
    
    
}
