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
    
    let model: SidewalkSurfaceClassifier = {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            return try SidewalkSurfaceClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SidewalkSurfaceClassifier")
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
        let mlArray = try! MLMultiArray(x)

        // 予測させる
        guard let output = try? self.model.prediction(input: SidewalkSurfaceClassifierInput(input: mlArray)) else {
            fatalError("Unexpected runtime error.")
        }
        
        // 予測ラベル
        self.prediction = output.classLabel
        
        // Softmaxの出力
        self.asphaltSoftmax = output.Identity["asphalt"]!
        self.gravelSoftmax = output.Identity["gravel"]!
        self.lawnSoftmax = output.Identity["lawn"]!
        self.grassSoftmax = output.Identity["grass"]!
        self.sandSoftmax = output.Identity["sand"]!
        self.matSoftmax = output.Identity["mat"]!
                
        return output.classLabel
    }
}
