//
//  WelcomeView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/21/20.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var showingAdd = false
    @State var showingRandom = false
    @State var showingFavorite = false
    @State var tapCount = 0
    
    var body: some View {
            ZStack {
                
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                
                VStack() {
                    TitleView()
                        .padding(.all, 20)
                    
                    Spacer()
                    VStack(alignment: .leading) {
                        
                        if showingAdd {
                            InfoView(title: "Add", subTitle: "Add names to the hat by tapping the Add Names button, then typing a name you want to add.", imageName: "plus.circle.fill")
                                .transition(.move(edge: .leading))
                        }
                        
                        if showingRandom {
                            InfoView(title: "Randomize", subTitle: "Pick random names out of the hat at random by tapping the hat button.", imageName: "rectangle.stack.fill")
                                .transition(.move(edge: .leading))
                        }
                        
                        if showingFavorite {
                            InfoView(title: "Favorite", subTitle: "Save names for later use by clicking the heart icon in the bottom right corner of the card.", imageName: "heart.fill")
                                .transition(.move(edge: .leading))
                        }
                        
                    }.padding()
                    
                    Spacer()
                    Spacer()
                    Button(action: {
                        
                        self.tapCount += 1
                        
                        withAnimation {
                            
                            if self.tapCount == 1 {
                                self.showingAdd.toggle()
                            }
                            
                            if self.tapCount == 2 {
                                self.showingRandom.toggle()
                            }
                            
                            if self.tapCount == 3 {
                                self.showingFavorite.toggle()
                            }
                            
                            if self.tapCount == 4 {
                                self.tapCount = 0
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                    }) {
                        
                        Text(self.tapCount == 3 ? "Done" : "Continue")
                            .padding()
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color("AccentColor")))
                            .animation(.default)
                    }.shadow(radius: 3)
                    
                }.padding(.horizontal)
                    .animation(.spring())
            }
        }
    }

    struct TitleView: View {
        
        var body: some View {
            VStack {

                Text("Welcome To")
                    .customStyleText()
                
                Text("Virtual Hat")
                    .customStyleText()
                .foregroundColor(Color("AccentColor"))
            }
        }
    }

    struct InfoView: View {
        
        var title: String
        var subTitle: String
        var imageName: String
        
        var body: some View {
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .font(.largeTitle)
                    .foregroundColor(Color("AccentColor"))
                    .padding()
                    .accessibility(hidden: true)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibility(addTraits: .isHeader)
                    
                    Text(subTitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top)
        }
    }

    struct ButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color("AccentColor")))
            
        }
    }

    extension View {
        func customButton() -> ModifiedContent<Self, ButtonModifier> {
            return modifier(ButtonModifier())
        }
    }

    extension Text {
        func customStyleText() -> Text {
            self
            .fontWeight(.black)
            .font(.system(size: 36))
        }
    }

    extension Color {
        static var testColor = Color(UIColor.systemIndigo)
    }
