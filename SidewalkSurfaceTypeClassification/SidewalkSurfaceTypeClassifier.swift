//
//  SidewalkSurfaceTypeClassifier.swift
//  SidewalkSurfaceTypeClassification
//
//  Created by MacBook Air Lab on 2020/08/11.
//  Copyright © 2020 MacBook Air Lab. All rights reserved.
//

import Foundation
import CoreML

class SidewalkSurfaceTypeClassifier: NSObject, ObservableObject {
//    let model = SidewalkSurfaceTypeModel()
    
    let model: SidewalkSurfaceTypeModel = {
        do {
            let config = MLModelConfiguration()
            return try SidewalkSurfaceTypeModel(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SidewalkSurfaceTypeModel")
        }
    }()
    
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
        print(output.dense_3)
        
        return output.classLabel
    }
}
