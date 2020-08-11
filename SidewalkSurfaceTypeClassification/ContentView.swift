//
//  ContentView.swift
//  SidewalkSurfaceTypeClassification
//
//  Created by MacBook Air Lab on 2020/08/11.
//  Copyright © 2020 MacBook Air Lab. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var starting = false
    @State private var isSharePresented = false

    @ObservedObject var manager = AccelerometerManager()
    
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 3104)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // 保存ボタン
                Button(action: {
                    
                }){
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Save")
                    }
                }
                .sheet(isPresented: $isSharePresented, content: {
                    // ActivityViewControllerを表示
                    ActivityViewController(activityItems: [], applicationActivities: nil)
                })
                
                Spacer()
                
                // 計測ボタン
                Button(action: {
                    self.starting.toggle()
                    
                    let switchFeedback = UIImpactFeedbackGenerator(style: .medium)
                    switchFeedback.impactOccurred()
                    
                    if self.starting {
                        // バックグラウンドタスク
                        self.backgroundTaskID =
                        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                        
                        // 計測スタート
                        self.manager.startUpdate(50.0)
                    }
                    else {
                        self.manager.stopUpdate()
                        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                    }
                }){
                    if self.starting {
                       HStack {
                                Image(systemName: "pause.circle")
                                Text("Stop")
                            }
                    }
                    else {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Start")
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            VStack {
                if self.manager.classifier.prediction == "asphalt" {
                    Image(systemName: "tortoise").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Asphalt")
                }
                else if self.manager.classifier.prediction == "gravel" {
                    Image(systemName: "circle.grid.3x3").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Gravel")
                }
                else if self.manager.classifier.prediction == "lawn" {
                    Image(systemName: "leaf.arrow.circlepath").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Lawn")
                }
                else if self.manager.classifier.prediction == "grass" {
                    Image(systemName: "ant").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Grass")
                }
                else if self.manager.classifier.prediction == "sand" {
                    Image(systemName: "sun.haze").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Sand")
                }
                else if self.manager.classifier.prediction == "mat"{
                    Image(systemName: "snow").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("Mat (Snow)")
                }
                else {
                    Image(systemName: "questionmark").resizable().scaledToFit().frame(width: 70, height: 70)
                    Text("None")
                }
            }.padding(.vertical)
            
            // 加速度の値を表示する
            VStack(alignment: .leading) {
                Text("Accelerometer")
                    .font(.headline)
                
                HStack {
                    Text(String(format: "%.3f", self.manager.x))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", self.manager.y))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(String(format: "%.3f", self.manager.z))
                        .multilineTextAlignment(.leading)
                    
                }.padding(.horizontal)
            }.padding(25)
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// UIActivityViewController on SwiftUI
struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
