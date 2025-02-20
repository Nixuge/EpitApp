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
            print("Done parsing.")
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
            let firstDepth = try doc.select("div#bloc_0_TITRE > table > tbody > tr.dsp_data_tr")

            var columns: [String] = []
            for columnRaw in try firstDepth[0].select("td.dsp_data_td_data") {
                columns.append(try columnRaw.text())
            }
            let year = try firstDepth[2].select("td.dsp_data_td_data").text().trimmingCharacters(in: .whitespacesAndNewlines)

            return PegasusYear(
                columns: columns,
                year: year,
                semesters: try parseSemesters(rootElement: firstDepth[3])
            )
        }

        private func parseSemesters(rootElement: Element) throws -> [PegasusSemester] {
            var semesters: [PegasusSemester] = []
            let secondDepth = try rootElement.select("> td > div > table > tbody > tr")
            for i in 0..<secondDepth.count where i % 2 == 0 {
                let semesterRow = secondDepth[i]
                let semesterMeta = try semesterRow.select("td")

                let currentSemester = PegasusSemester(
                    _weirdYear: try semesterMeta[2].text(),
                    label: try semesterMeta[3].text(),
                    localisations: try parseLocalisations(rootElement: secondDepth[i + 1])
                )

                semesters.append(currentSemester)
            }
            return semesters
        }

        private func parseLocalisations(rootElement: Element) throws -> [PegasusLocalisation] {
            var localisations: [PegasusLocalisation] = []
            let thirdDepth = try rootElement.select("> td > div > table > tbody > tr")
            for i in 0..<thirdDepth.count where i % 2 == 0 {
                let row = thirdDepth[i]
                let meta = try row.select("td")

                let weirdY = try meta[3].text()
                let label = try meta[4].text()
                if (weirdY.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    print("Item seems empty, skipping row.")
                    continue
                }

                let currentLocalisation = PegasusLocalisation(
                    _weirdYear: weirdY,
                    label: label,
                    compensations: try parseCompensations(rootElement: thirdDepth[i + 1])
                )

                localisations.append(currentLocalisation)
            }
            return localisations
        }

        private func parseCompensations(rootElement: Element) throws -> [PegasusCompensation] {
            var compensations: [PegasusCompensation] = []
            let fourthDepth = try rootElement.select("> td > div > table > tbody > tr")

            for i in 0..<fourthDepth.count where i % 2 == 0 {
                let row = fourthDepth[i]
                let meta = try row.select("td")

                let currentCompensation = PegasusCompensation(
                    _weirdYear: try meta[4].text(),
                    label: try meta[5].text(),
                    UEs: try parseUEs(rootElement: fourthDepth[i + 1])
                )

                compensations.append(currentCompensation)
            }
            return compensations
        }

        private func parseUEs(rootElement: Element) throws -> [PegasusUE] {
            var UEs: [PegasusUE] = []
            let fifthDepth = try rootElement.select("> td > div > table > tbody > tr")

            for i in 0..<fifthDepth.count where i % 2 == 0 {
                let row = fifthDepth[i]
                let meta = try row.select("td")

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
                    ECUEs: try parseECUEs(rootElement: fifthDepth[i + 1])
                )

                UEs.append(currentUE)
            }
            return UEs
        }

        private func parseECUEs(rootElement: Element) throws -> [PegasusECUE] {
            var ECUEs: [PegasusECUE] = []
            let sixthDepth = try rootElement.select("> td > div > table > tbody > tr")

            for i in 0..<sixthDepth.count where i % 2 == 0 {
                let row = sixthDepth[i]
                let meta = try row.select("td")

                let currentECUE = PegasusECUE(
                    _weirdYear: try meta[6].text(),
                    label: try meta[7].text(),
                    averageNote: Float(try meta[9].text()),
                    retakeNote: Float(try meta[10].text()),
                    inner: try parseInnerECUE(rootElement: sixthDepth[i + 1])
                )

                ECUEs.append(currentECUE)
            }
            return ECUEs
        }

        private func parseInnerECUE(rootElement: Element) throws -> [PegasusECUEInner] {
            var innerECUEs: [PegasusECUEInner] = []
            let seventhDepth = try rootElement.select("> td > div > table > tbody > tr")

            for i in 0..<seventhDepth.count where i % 2 == 0 {
                let row = seventhDepth[i]
                let meta = try row.select("td")

                let currentInnerECUE = PegasusECUEInner(
                    _weirdYear: try meta[7].text(),
                    label: try meta[8].text(),
                    averageNote: Float(try meta[10].text()),
                    grades: try parseGrades(rootElement: seventhDepth[i + 1])
                )

                innerECUEs.append(currentInnerECUE)
            }
            return innerECUEs
        }

        private func parseGrades(rootElement: Element) throws -> [PegasusGrade] {
            var grades: [PegasusGrade] = []
            let eighthDepth = try rootElement.select("> td > div > table > tbody > tr")
            if eighthDepth.isEmpty {
                return []
            }

            for i in 0..<eighthDepth.count where i % 2 == 0 {
                let row = eighthDepth[i]
                let meta = try row.select("td")

                let rawGrade = try meta[18].text()
                var grade: PegasusGradeValue
                if rawGrade == "ABSJ" {
                    grade = PegasusGradeValue(type: .absj)
                } else if rawGrade == "ABSNJ" {
                    grade = PegasusGradeValue(type: .absnj)
                } else if let floatValue = Float(rawGrade) {
                    grade = PegasusGradeValue(type: .float, value: floatValue)
                } else {
                    grade = PegasusGradeValue(type: .unset)
                }

                let currentGrade = PegasusGrade(
                    noteType: try meta[16].text(),
                    date: try meta[17].text(),
                    note: grade
                )
                grades.append(currentGrade)
            }
            return grades
        }
}
