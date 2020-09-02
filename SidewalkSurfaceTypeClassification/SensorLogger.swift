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
    var logger = AccelerometerDataLogger()
    
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
            
            // タイムスタンプを保持する
            self.logger.logTimestamp()
        }
        else {
            self.x = Double.nan
            self.y = Double.nan
            self.z = Double.nan
        }
        
        // dataの長さがclassifier.x_lengthになったら予測させる
        if self.data.count == self.classifier.x_length {
            let predict = self.classifier.predict(x: self.data)
            
            // 予測値とデータを保持する
            self.logger.logData(data: self.data, estimated: predict)
            
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
        self.logger.resetTimestamps()
    }
    
}

class AccelerometerDataLogger {
    var data: String
    var timestamps = [String]()
    
    public init() {
        let column = "time,x,y,z,estimated\n"
        self.data = column
    }
    
    private func getTimestamp() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return format.string(from: Date())
    }
    
    func logTimestamp() {
        self.timestamps.append(self.getTimestamp())
    }
    
    func resetTimestamps() {
        self.timestamps = [String]()
    }
    
    private func logOneLineData(time: String, x: Double, y: Double, z: Double, estimated: String) {
        var line = time + ","
        line.append(contentsOf: String(x) + ",")
        line.append(contentsOf: String(y) + ",")
        line.append(contentsOf: String(z) + ",")
        line.append(contentsOf: estimated + "\n")
        
        self.data.append(contentsOf: line)
    }
    
    // 256*3のセンサデータを記録する
    func logData(data: [Double], estimated: String) {
        // タイムスタンプとセンサデータの長さが合わない場合
        if self.timestamps.count != data.count / 3 {
            fatalError("Error: The length won't match.")
        }
        
        for i in 0..<self.timestamps.count {
            self.logOneLineData(time: self.timestamps[i], x: data[3 * i], y: data[3 * i + 1], z: data[3 * i + 2], estimated: estimated)
        }
        
        self.timestamps = [String]()
    }
    
    // 保存
    func getDataURL() -> [URL] {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let dataFilepath = tmppath + "/accelerometer_estimated_\(time).csv"
        
        do {
            try self.data.write(toFile: dataFilepath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("Failure to Write File\n\(error)")
        }
    
        var urls = [URL]()
        urls.append(URL(fileURLWithPath: dataFilepath))
        
        self.resetData()
        
        return urls
    }
    
    func resetData() {
        let column = "time,x,y,z,estimated\n"
        self.data = column
    }
}
