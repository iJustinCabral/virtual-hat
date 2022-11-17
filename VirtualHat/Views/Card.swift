//
//  Card.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI

struct Card: View {
    
    var name: String
    var showOverlay = false
    var isSaved = false
    var save: () -> Void = {}
    var delete: () -> Void = {}
  
    var body: some View {
        if showOverlay {
            Text("\(name)")
                .font(.title)
                .padding(.all, 10)
                .frame(width: 300, height: 200)
                .background(Color("cardColor"))
                .foregroundColor(.primary)
                .cornerRadius(8.0)
                .shadow(radius: 3)
                .transition(.scale)
                .overlay(Button(action: {
                    save()
                }) {
                    if isSaved {
                        Image(systemName: "heart.fill")
                            .renderingMode(.template)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.all, 10)
                    } else {
                        Image(systemName: "heart")
                            .renderingMode(.template)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.all, 10)
                    }
                    
                }, alignment: .bottomTrailing)
                .overlay(Button(action:{
                    
                    withAnimation {
                        delete()
                    }
                    
                }) {
                    
                    Image(systemName: "trash.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                        .padding(.all, 10)
                    
                }, alignment: .bottomLeading)
        }
        else {
            Text("\(name)")
                .font(.title)
                .padding(.all, 10)
                .frame(width: 300, height: 200)
                .background(Color("cardColor"))
                .foregroundColor(.primary)
                .cornerRadius(8.0)
                .shadow(radius: 3)
                .transition(.scale)
        }
    }
}


struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Card(name: "Justin", showOverlay: false)
                
        }
    }
}


struct FlipView<Front: View, Back: View> : View {
    var isFlipped: Bool
    var front: () -> Front
    var back: () -> Back
    
    init(isFlipped: Bool, @ViewBuilder front: @escaping () -> Front, @ViewBuilder back: @escaping () -> Back) {
        self.isFlipped = isFlipped
        self.front = front
        self.back = back
    }
    
    var body: some View {
        ZStack {
            front()
                .rotation3DEffect( .degrees(isFlipped == true ? 180 : 0), axis: (x: 0.0, y: 1.0, z: 0.0))
                .opacity(isFlipped == true ? 0 : 1)
                .accessibility(hidden: isFlipped == true)
            
            back()
                .rotation3DEffect( .degrees(isFlipped == true ? 0 : -180), axis: (x: 0.0, y: 1.0, z: 0.0))
                .opacity(isFlipped == true ? 1 : -1)
                .accessibility(hidden: isFlipped == false)
        }.transition(.scale)
    }
}
