//
//  AddView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI
import OSLog

enum ActiveAlert: Identifiable {
    case empty,duplicate,long, saved
    
    var id: Int {
        return self.hashValue
    }
}

struct AddView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var hat: Hat
    
    @FetchRequest(entity: Person.entity(), sortDescriptors: []) var people: FetchedResults<Person>

    @State private var name = ""
    @State private var savedName = ""
    @State private var isShowingEmptyNameAlert = false
    @State private var isShowingDuplicateAlert = false
    @State private var isShowingTooLongAlert = false
    @State private var isShowingAlreadySaved = false
    @State private var isShowingOverlay = false
    @State private var isEditing = false
    @State private var activeAlert: ActiveAlert?
    
    let columns = [ GridItem(.fixed(80))]
    let logger = Logger()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                
                if isShowingOverlay {
                    OverlayView(message: "The Hat is Empty", subMessage: "Add names to the hat.")
                }
                
                VStack {
                    
                    ScrollView {
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(hat.names, id: \.self) { person in
                                Card(name: person.name ?? "unkown name", showOverlay: true, isSaved: hat.checkSavedDuplicates(person: person), save: {
                                    if hat.checkSavedDuplicates(person: person) == false {
                                        person.saved = true
                                        hat.save(person)
                                        saveContext()
                                    }
                                    else {
                                        person.saved = false
                                        hat.deleteSaved(person)
                                        saveContext()
                                    }
                                    HapticGenerator.shared.generateHaptic(.light)
                    
                                }, delete: {
                                    
                                    moc.delete(person)
                                    saveContext()
                                    
                                    withAnimation {
                                        hat.delete(person)
                                        HapticGenerator.shared.generateHaptic(.light)
                                    }
                                })
                            }
                        }
                        .padding(.all)
                        
                    }
                    .shadow(radius: 3)
                    
                    AddBarView(name: $name) {
                        if name.count >= 1 && name.count <= 20 {
                            let person = Person(context: moc)
                            let trimmedName = name.trimmingCharacters(in: .whitespaces)
                            person.name = trimmedName
                            person.mained = true
                            
                            if hat.checkDuplicate(person: person) == true {
                                activeAlert = .duplicate
                                name = ""
                                HapticGenerator.shared.generateHaptic(.error)
                            } else {
                            
                                withAnimation {
                                    hat.add(person)
                                    saveContext()
                                    name = ""
                                    HapticGenerator.shared.generateHaptic(.success)
                                    
                                    logger.info("people: \(people.count)")
                                    logger.info("")
                                }
                            }
                            
                        } else if name.count > 20 {
                            activeAlert = .long
                            HapticGenerator.shared.generateHaptic(.error)

                        }
                        else {
                            activeAlert = .empty
                            HapticGenerator.shared.generateHaptic(.error)
                        }
                    }
                
                    Spacer()
                    
                }
                .onAppear(perform: checkEmpty)
                .onChange(of: hat.isEmpty, perform: { value in
                    withAnimation {
                        isShowingOverlay.toggle()
                    }
                })
                .navigationBarTitle("Add Names")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                        leading:
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                    }, trailing:
                        Text("Total: \(hat.count)")
                            .foregroundColor(Color("AccentColor"))
                )
                .alert(item: $activeAlert) { item in
                    switch activeAlert {
                    case .empty:
                        return Alert(title: Text("Empty Name"), message: Text("You cannot add an empty name to the hat."), dismissButton: .default(Text("OK")))
                    case .long:
                        return Alert(title: Text("Too Many Characters"), message: Text("You cannot add a name that consists of more than 20 characters."), dismissButton: .default(Text("OK")))
                    case .duplicate:
                        return Alert(title: Text("Duplicate Name"), message: Text("You cannot add two of the same name to the hat."), dismissButton: .default(Text("OK")))
                    case .saved:
                        return Alert(title: Text("Already Saved"), message: Text("A person with the name \(savedName) has already been saved."), dismissButton: .default(Text("OK")))
                    case .none:
                        return Alert(title: Text("None"))
                    }
                }
            }
        }
    }
    
    private func checkEmpty() {
        if hat.names.isEmpty == true {
            isShowingOverlay = true
        } else {
            isShowingOverlay = false
        }
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Could not save context \(error)")
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView().environmentObject(Hat(names: [], pulledNames: [], savedNames: []))
    }
}

struct AddBarView: View {
    
    @Binding var name: String
    var onCommit : () -> Void
    
    var body: some View {
        HStack {
            
            TextField("Enter a name...", text: $name, onCommit:  { onCommit() })
                .keyboardType(.alphabet)
                .textContentType(.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(radius: 3)
            
            Text("\(name.count) / 20")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(name.count > 20 ? .red : .primary)
                .padding(.horizontal, 6)
            
        }.padding(.horizontal)
    }
}
