//
//  SensorLogger.swift
//  SidewalkSurfaceTypeClassification
//
//  Created by MacBook Air Lab on 2020/08/11.
//  Copyright © 2020 MacBook Air Lab. All rights reserved.
//

import Foundation
import CoreMotion
import Combine

class AccelerometerManager: NSObject, ObservableObject {
    var motionManager: CMMotionManager!
    var classifier = SidewalkSurfaceTypeClassifier()
    
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var z = 0.0
    
    @Published var data = [Double]()
    
    private var timer = Timer()
    private var length = 0
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
    }
    
    @objc private func startSensor() {
        
        if let data = self.motionManager?.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            
            self.x = x
            self.y = y
            self.z = z
            
            // 予測用
            self.data.append(x)
            self.data.append(y)
            self.data.append(z)
        }
        else {
            self.x = Double.nan
            self.y = Double.nan
            self.z = Double.nan
        }
        
        // dataの長さがclassifier.x_lengthになったら予測させる
        if self.data.count == self.classifier.x_length {
            let _ = self.classifier.predict(x: self.data)
            
            self.data = [Double]()
        }
    }
    
    func startUpdate(_ freq: Double) {
        if self.motionManager!.isAccelerometerAvailable {
            self.motionManager?.startAccelerometerUpdates()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / freq,
                                          target: self,
                                          selector: #selector(self.startSensor),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func stopUpdate() {
        self.timer.invalidate()
        
        if self.motionManager!.isAccelerometerActive {
            self.motionManager?.stopAccelerometerUpdates()
        }
        
        self.data = [Double]()
    }
    
}
