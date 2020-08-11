//
//  SidewalkSurfaceTypeClassifier.swift
//  SidewalkSurfaceTypeClassification
//
//  Created by Satoshi on 2020/08/11.
//  Copyright © 2020 Satoshi. All rights reserved.
//

import Foundation
import CoreML

class SidewalkSurfaceTypeClassifier: NSObject, ObservableObject {
    let model = SidewalkSurfaceTypeModel()
    let x_length: Int = 256 * 3
    @Published var prediction: String = "None"
    
    
    func predict(x: [Double]) -> String {
        // 長さがx_lengthではない場合は予測できない
        if x.count != self.x_length {
            return "None"
        }
        
        // MLMultiArrayに変換する
        let mlArray = try! MLMultiArray(shape: [self.x_length as NSNumber], dataType: MLMultiArrayDataType.double)
        
        for (index, data) in x.enumerated() {
            mlArray[index] = data as NSNumber
        }

        // 予測させる
        guard let output = try? self.model.prediction(input: SidewalkSurfaceTypeModelInput(input_2: mlArray)) else {
            fatalError("Unexpected runtime error.")
        }
        
        self.prediction = output.classLabel
        print(output.classLabel)
        
        return output.classLabel
    }
}
