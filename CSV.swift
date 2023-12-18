//
//  CSV.swift
//  ParseCSV2
//
//  Created by Allen Norskog on 10/30/23.
//

import Foundation

struct CSV {

}
// Will need to work on later and need to download the image from the code we created.
extension CSV {
    static func parse(fileName: String) -> [[Double]] {
        var result: [[Double]] = []
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "csv"){
            do{
                let s = try String(contentsOf: url).replacingOccurrences(of: " ", with: "")
                    let lines = s.split(whereSeparator: \.isNewline)
                    for line in lines {
                        var row: [Double] = []
                        let columns = line.split(separator: ",")
                        for column in columns {
                            if let num = Double(column){
                                row.append(num)
                            }
                        }
                        result.append(row)
                    }

            } catch{
                print("Unable to load file")
            }
        }
        return result
        
    }

}
