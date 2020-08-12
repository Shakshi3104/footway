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
    
    @Published var asphaltSoftmax: Double = Double.nan
    @Published var gravelSoftmax: Double = Double.nan
    @Published var lawnSoftmax: Double = Double.nan
    @Published var grassSoftmax: Double = Double.nan
    @Published var sandSoftmax: Double = Double.nan
    @Published var matSoftmax: Double = Double.nan
    
    
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
        
        // 予測ラベル
        self.prediction = output.classLabel
        
        // Softmaxの出力
        self.asphaltSoftmax = output.dense_3["asphalt"]!
        self.gravelSoftmax = output.dense_3["gravel"]!
        self.lawnSoftmax = output.dense_3["lawn"]!
        self.grassSoftmax = output.dense_3["grass"]!
        self.sandSoftmax = output.dense_3["sand"]!
        self.matSoftmax = output.dense_3["mat"]!
        
        print(output.classLabel)
        print(output.dense_3)
        
        return output.classLabel
    }
}
