//
//  PegasusParser.swift
//  EpitApp
//
//  Created by Quenting on 19/02/2025.
//

import SwiftUI
import SwiftSoup

enum PegasusProgressState {
    case fetching, parsing, done, errorFetching, errorParsing
}

struct PegasusYear {
    let columns: [String]
    let year: String
    var semesters: [PegasusSemester]
}
struct PegasusSemester {
    let _weirdYear: String
    let label: String
    var localisations: [PegasusLocalisation]
}
struct PegasusLocalisation {
    let _weirdYear: String
    let label: String
    var compensations: [PegasusCompensation]
}
struct PegasusCompensation {
    let _weirdYear: String
    let label: String
    var UEs: [PegasusUE]
}
enum UEState {
    case validated, unvalidated
}
struct PegasusUE {
    let _weirdYear: String
    let label: String
    let averageNote: Float?
    let state: UEState?
    var ECUEs: [PegasusECUE]
    
}
struct PegasusECUE {
    let _weirdYear: String
    let label: String
    let averageNote: Float?
    let retakeNote: Float?
    var inner: [PegasusECUEInner]
}
struct PegasusECUEInner {
    let _weirdYear: String
    let label: String
    let averageNote: Float?
    var grades: [PegasusGrade]
}
struct PegasusGrade {
    let noteType: String
    let date: String // TODO?: Date
    let note: PegasusGradeValue
}
enum PegasusGradeValueType {
    case unset, absj, absnj, float
}
struct PegasusGradeValue {
    let type: PegasusGradeValueType
    let value: Float?
    
    init(type: PegasusGradeValueType, value: Float? = nil) {
        self.type = type
        self.value = value
    }
}


class PegasusParser: ObservableObject {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @Published var progressState: PegasusProgressState
    @Published var data: PegasusYear?

    init(pegasusAuthModel: PegasusAuthModel) {
        self.pegasusAuthModel = pegasusAuthModel
        self.progressState = .fetching
        self.data = nil
        DispatchQueue.background(completion:  {
            Task {
                await self.parseAll()
            }
        })

    }

    private func parseAll() async {
        self.progressState = .fetching
        guard let rawContent = await fetchData() else {
            self.progressState = .errorFetching
            return
        }
        
        self.progressState = .parsing
        print("Done fetching.")
        
        DispatchQueue.background(background:  {
            guard let parsed = self.parseDate(rawContent: rawContent) else {
                DispatchQueue.main.async {
                    self.progressState = .errorParsing
                }
                return
            }
            
            DispatchQueue.main.async {
                self.data = parsed
                self.progressState = .done
            }
            print(parsed)
        })
    }
    
    private func fetchData() async -> String? {
        let url = NSURL(string: "https://prepa-epita.helvetius.net/pegasus/index.php?com=extract&job=extract-notes")
        
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        print("PHPSESSID=\(pegasusAuthModel.pegasusPhpSessId!)")
        request.setValue("PHPSESSID=\(pegasusAuthModel.pegasusPhpSessId!)", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
                
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let res = response as? HTTPURLResponse, res.statusCode == 200 else {
                print("Invalid response.")
                return nil
            }

            guard let responseString = String(data: data, encoding: .isoLatin1) else {
                print("Failed to convert data to string.")
                return nil
            }

            return responseString
        } catch {
            return nil
        }
    }
    
    private func parseDate(rawContent: String) -> PegasusYear? {
        do {
            
            let doc = try SwiftSoup.parse(rawContent)

            return try parseYear(doc: doc)
        } catch Exception.Error(let type, let message) {
            self.progressState = .errorParsing
            return nil
        } catch {
            self.progressState = .errorParsing
            return nil
        }
    }
    
    private func parseYear(doc: Document) throws -> PegasusYear {
        var currentPath = "div#bloc_0_TITRE > table > tbody > tr.dsp_data_tr"
        
        let firstDepth = try doc.select(currentPath)
        
        // Parse top row(s)
        var columns: [String] = []
        for columnRaw in try firstDepth[0].select("td.dsp_data_td_data") {
            columns.append(try columnRaw.text())
        }
        let year = try firstDepth[2].select("td.dsp_data_td_data").text().trimmingCharacters(in: .whitespacesAndNewlines)

        return PegasusYear(
            columns: columns,
            year: year,
            semesters: try parseSemesters(doc: doc, path: currentPath + ":nth-of-type(4) > td > div > table > tbody > tr")
        )
    }
    
    private func parseSemesters(doc: Document, path: String) throws -> [PegasusSemester] {
        //TODO: HANDLE 0 ON BOTH THIS & PARSELOCATIONS
        //TODO: HAndle weird note between semester & localisation
        var semesters: [PegasusSemester] = []
        let secondDepth = try doc.select(path)
        for i in 0...((secondDepth.count/2)-1){ // Semester are only at the odd places, their data at even places.
            let semesterRow = i*2
            let semesterMeta = try secondDepth[semesterRow].select("td")

            let currentSemester = PegasusSemester(
                _weirdYear: try semesterMeta[2].text(),
                label: try semesterMeta[3].text(),
                // html index = 1, and +1 compaired to i
                localisations: try parseLocalisations(doc: doc, path: path + ":nth-of-type(\(semesterRow+2)) > td > div > table > tbody > tr")
            )
            
            semesters.append(currentSemester)
        }
        return semesters
    }
    private func parseLocalisations(doc: Document, path: String) throws -> [PegasusLocalisation] {
        var localisations: [PegasusLocalisation] = []
        let thirdDepth = try doc.select(path)
        for i in 0...((thirdDepth.count/2)-1){
            let row = i*2
            let meta = try thirdDepth[row].select("td")
            
            let weirdY = try meta[3].text()
            let label = try meta[4].text()
            // For some reason, theres an annoying grade thats just in there for some reason.
            if (weirdY.trimmingCharacters(in: .whitespacesAndNewlines) == "" || label.trimmingCharacters(in: .whitespacesAndNewlines) == "" ) {
                print("Item seem empty, skipping row.")
                continue
            }
                        
            let currentLocalisation = PegasusLocalisation(
                _weirdYear: weirdY,
                label: label,
                compensations: try parseCompensations(doc: doc, path: path + ":nth-of-type(\(row+2)) > td > div > table > tbody > tr")
            )
            
            localisations.append(currentLocalisation)
        }
        return localisations
    }
    
    private func parseCompensations(doc: Document, path: String) throws -> [PegasusCompensation] {
        var compensations: [PegasusCompensation] = []
        let fourthDepth = try doc.select(path)

        for i in 0...((fourthDepth.count/2)-1){
            let row = i*2
            let meta = try fourthDepth[row].select("td")

            let currentLocalisation = PegasusCompensation(
                _weirdYear: try meta[4].text(),
                label: try meta[5].text(),
                UEs: try parseUEs(doc: doc, path: path + ":nth-of-type(\(row+2)) > td > div > table > tbody > tr")
            )
            
            compensations.append(currentLocalisation)
        }
        return compensations
    }
    
    private func parseUEs(doc: Document, path: String) throws -> [PegasusUE] {
        var UEs: [PegasusUE] = []
        let fifthDepth = try doc.select(path)

        for i in 0...((fifthDepth.count/2)-1){
            let row = i*2
            let meta = try fifthDepth[row].select("td")
            
            let state: UEState?
            switch try meta[10].text() {
                case "VA":
                    state = .validated
                case "NV":
                    state = .unvalidated
                default:
                    state = nil
            }
            
            let currentUE = PegasusUE(
                _weirdYear: try meta[5].text(),
                label: try meta[6].text(),
                averageNote: Float(try meta[8].text()),
                state: state,
                ECUEs: try parseECUEs(doc: doc, path: path + ":nth-of-type(\(row+2)) > td > div > table > tbody > tr")
            )
            
            UEs.append(currentUE)
        }
        return UEs
    }
    
    private func parseECUEs(doc: Document, path: String) throws -> [PegasusECUE] {
        var ECUEs: [PegasusECUE] = []
        let fifthDepth = try doc.select(path)

        for i in 0...((fifthDepth.count/2)-1){
            let row = i*2
            let meta = try fifthDepth[row].select("td")
            
            let currentECUE = PegasusECUE(
                _weirdYear: try meta[6].text(),
                label: try meta[7].text(),
                averageNote: Float(try meta[9].text()),
                retakeNote: Float(try meta[10].text()),
                inner: try parseInnerECUE(doc: doc, path: path + ":nth-of-type(\(row+2)) > td > div > table > tbody > tr")
            )
            
            ECUEs.append(currentECUE)
        }
        return ECUEs
    }
    
    private func parseInnerECUE(doc: Document, path: String) throws -> [PegasusECUEInner] {
        var innerECUEs: [PegasusECUEInner] = []
        let sixthDepth = try doc.select(path)
        
        
        for i in 0...((sixthDepth.count/2)-1){
            let row = i*2
            let sixthDepth = try doc.select(path)
                        
            let meta = try sixthDepth[row].select("td")

            let currentInnerECUE = PegasusECUEInner(
                _weirdYear: try meta[7].text(),
                label: try meta[8].text(),
                averageNote: Float(try meta[10].text()),
                grades: try parseGrades(doc: doc, path: path + ":nth-of-type(\(row+2)) > td > div > table > tbody > tr")
            )
            
            innerECUEs.append(currentInnerECUE)
        }
        return innerECUEs
    }
    
    private func parseGrades(doc: Document, path: String) throws -> [PegasusGrade] {
        var grades: [PegasusGrade] = []
        let seventhDepth = try doc.select(path)
        if (seventhDepth.count == 0) {
            return []
        }
        
        for i in 0...((seventhDepth.count/2)-1){
            let row = i*2
            let sixthDepth = try doc.select(path)
                        
            let meta = try seventhDepth[row].select("td")
            
            // Values possible:
            // "Pas de notes"
            // "ABSJ"
            // "ABSNJ"
            
            let rawGrade = try meta[18].text()
            var grade: PegasusGradeValue
            if (rawGrade == "ABSJ") {
                grade = PegasusGradeValue(type: .absj)
            } else if (rawGrade == "ABSNJ") {
                grade = PegasusGradeValue(type: .absnj)
            } else if (Float(rawGrade)) != nil {
                grade = PegasusGradeValue(type: .float, value: Float(rawGrade)!)
            } else {
                grade = PegasusGradeValue.init(type: .unset)
            }
            
            
            
            let currentGrade = PegasusGrade(
                noteType: try meta[16].text(),
                date:  try meta[17].text(),
                note: grade
            )
            grades.append(currentGrade)
        }
        return grades
    }
}
