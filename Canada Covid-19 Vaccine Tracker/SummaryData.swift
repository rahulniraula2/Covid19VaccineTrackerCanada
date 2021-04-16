

import Foundation

// MARK: - SummaryData
struct SummaryData: Codable {
    let data: [Datum]
    let lastUpdated: String
    let province: String

    enum CodingKeys: String, CodingKey {
        case data
        case lastUpdated = "last_updated"
        case province = "province"
    }
}

// MARK: - Datum
struct Datum: Codable {
    let Date : String
    let changeCases, changeFatalities, changeTests: Int?
    let changeHospitalizations, changeCriticals, changeRecoveries, changeVaccinations: Int?
    let changeVaccinated, changeVaccinesDistributed, totalCases, totalFatalities: Int?
    let totalTests, totalHospitalizations, totalCriticals, totalRecoveries: Int?
    let totalVaccinations, totalVaccinated, totalVaccinesDistributed: Int?

    enum CodingKeys: String, CodingKey {
        case Date = "date"
        case changeCases = "change_cases"
        case changeFatalities = "change_fatalities"
        case changeTests = "change_tests"
        case changeHospitalizations = "change_hospitalizations"
        case changeCriticals = "change_criticals"
        case changeRecoveries = "change_recoveries"
        case changeVaccinations = "change_vaccinations"
        case changeVaccinated = "change_vaccinated"
        case changeVaccinesDistributed = "change_vaccines_distributed"
        case totalCases = "total_cases"
        case totalFatalities = "total_fatalities"
        case totalTests = "total_tests"
        case totalHospitalizations = "total_hospitalizations"
        case totalCriticals = "total_criticals"
        case totalRecoveries = "total_recoveries"
        case totalVaccinations = "total_vaccinations"
        case totalVaccinated = "total_vaccinated"
        case totalVaccinesDistributed = "total_vaccines_distributed"
    }
    
    
}

class graphData{
    var date : String
    var change : Int
    
    init(date : String, change: Int) {
        self.date = date
        self.change = change
    }
    
    func toString() -> String{
        return self.date + " : " + String(self.change)
    }
}

