//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Bryon Carlin on 8/16/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = wakeTime
    @State private var restAmount = 8.0
    @State private var caffeineDrink = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var wakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("What time do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep?")
                        .font(.headline)
                    Stepper("\(restAmount.formatted()) hours", value: $restAmount, in: 0...24, step: 0.250)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Caffeine intake today?")
                        .font(.headline)
                    Stepper("\(caffeineDrink.formatted()) drink", value: $caffeineDrink, in: 0...99)
                    
                }
            }
            .navigationTitle("BetterSleep")
            .toolbar {
                Button("Calculate", action: calculateSleep)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Ok") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func calculateSleep() {
        do {
            let config = MLModelConfiguration()
            let model = try RestCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: restAmount, coffee: Double(caffeineDrink))
            
            let sleepTime = wakeUpTime - prediction.actualSleep
            alertTitle = "Your bed time should be"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry can't calculate your estimated bed time"
        }
        showingAlert = true
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
