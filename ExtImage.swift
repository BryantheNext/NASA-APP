//
//  ExtImage.swift
//  ParseCSV2
//
//  Created by Allen Norskog on 10/30/23.
//



//Print a height image




import Foundation
import UIKit

extension UIImage {

    var pixelWidth: Int {
        return cgImage?.width ?? 0
    }

    var pixelHeight: Int {
        return cgImage?.height ?? 0
    }

}

// https://stackoverflow.com/questions/30958427/pixel-array-to-uiimage-in-swift

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension UIImage {
    convenience init?(pixels: [PixelData], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else { return nil }
        var data = pixels
        guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<PixelData>.size) as CFData)
        else { return nil }
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}

extension UIImage {
    static let slopeBlue = PixelData(a: 255, r: 0, g: 0, b: 128)
    static let slopeGreen = PixelData(a: 255, r: 0, g: 128, b: 0)
    static let slopeOrange = PixelData(a: 255, r: 255, g: 128, b: 0)
    static let slopeRed = PixelData(a: 255, r: 255, g: 0, b: 0)
    static let slopePurple = PixelData(a: 255, r: 145, g: 70, b: 255)
    static let slopeBlack = PixelData(a: 255, r: 0, g: 0, b: 0)
    static let slopeWhite = PixelData(a: 255, r: 255, g: 255, b: 255)
    static let slopeYellow = PixelData(a: 255, r: 255, g: 255, b: 191)

    static func colorSlope(_ value: Double) -> PixelData {
        // expand this function
  //Find the comparsen values for the other measurements to create a map.
//       var roundValue = round(value)
//        var minValue = min(roundValue, roundValue)
//        var maxValue = max(roundValue, roundValue)
//        print(minValue)
        //print(maxValue)
        
        if value >= 1200 {
            return slopeBlack
        }else if value > 900{
                return slopePurple
        }else{
            return slopeYellow
        }
    }
    static func colorize(data: [[Double]]) -> UIImage? {
        var pixelData: [PixelData] = []
        let numRows = data.count
        if numRows < 1 {
            print("ERROR: No data!")
            return nil
        }
        let numCols = data[0].count
        for i in 0..<numRows {
            if data[i].count != numCols {
                print("ERROR: Bad column count for row: \(i)!")
                print("ERROR: Expecting: \(numCols)  got: \(data[i].count)!")
                return nil
            }
        }

        for i in 0..<numRows {
            for j in 0..<numCols {
                pixelData.append(UIImage.colorSlope(data[i][j]))
            }
        }
        return UIImage(pixels: pixelData, width: numCols, height: numRows)
    }

}
