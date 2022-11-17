//
//  CharacterCountView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/24/20.
//

import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
    var trimAmount = 0.5
    var strokeColor = Color("AccentColor")
    var strokeWidth = 25.0
    var amount = 0
    let formatter = NumberFormatter()
    
    var rotation: Angle {
        Angle(radians: .pi * (1 - trimAmount)) + Angle(radians: .pi / 2)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        formatter.numberStyle = .percent
        let percentage = formatter.string(from: fractionCompleted as NSNumber) ?? "0%"
        
        return ZStack {
            Circle()
                .rotation(rotation)
                .trim(from: 0, to: CGFloat(trimAmount))
                .stroke(strokeColor.opacity(0.5), style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
            
            Circle()
                .rotation(rotation)
                .trim(from: 0, to: CGFloat(trimAmount * fractionCompleted))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
            
            Text(percentage)
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .offset(y: -20)
                .animation(nil)
        }
    }
}

struct CharacterCountView: View {
    
    @State private var progress = 0.0
    
    var body: some View {
        ProgressView("Label", value: progress, total: 20)
            .progressViewStyle(GaugeProgressStyle())
            .frame(width: 200)
            .onTapGesture {
                if progress  < 20 {
                    withAnimation {
                        progress += 1
                    }
                }
            }
    }
}

struct CharacterCountView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCountView()
    }
}
