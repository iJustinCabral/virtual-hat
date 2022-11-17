//
//  OverlayView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/26/20.
//

import SwiftUI

struct OverlayView: View {
    
    var message: String
    var subMessage: String
    
    var body: some View {
        
        ZStack {
            Color("cardColor")
                .cornerRadius(8.0)
                .frame(width: 300, height: 200)
                .shadow(radius: 3)
            VStack {
                Text(message)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding()
                Text(subMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .transition(.scale)
        
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(message: "The Hat is Empty", subMessage: "Add names to the hat")
    }
}
