//
//  SavedView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI
import OSLog

struct SavedView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var hat: Hat
    
    @FetchRequest(entity: Person.entity(), sortDescriptors: [], predicate: NSPredicate(format: "saved == true")) var savedPeople: FetchedResults<Person>

    @State private var selections: [Person] = []
    @State private var duplicateName: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var showAddButton: Bool = false
    @State private var isShowingOverlay: Bool = false
    
    let logger = Logger()

    var body: some View {
        NavigationView {
            ZStack {
                if isShowingOverlay {
                    OverlayView(message: "No Saved Names", subMessage: "Tap the heart button on a card to save a name")
                }
                
                VStack {
                    Section {
                        HStack {
                            Text("Selected: \(selections.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            if showAddButton {
                                Button(action: {
                                    addSelectionsToHat()
                                    HapticGenerator.shared.generateHaptic(.success)
                                }) {
                                    Text("Add to Hat")
                                        .fontWeight(.bold)
                                        .padding(.all, 10)
                                        .background(Color("AccentColor"))
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                        .cornerRadius(8.0)
                                    
                                }
                                .shadow(radius: 3)
                                .transition(.scale)
                            }
                            
                        }
                        .padding([.top, .horizontal])
                        .background(Color("backgroundColor"))
                        .onChange(of: selections.isEmpty, perform: { value in
                            withAnimation {
                                self.showAddButton.toggle()
                            }
                        })
                        
                    }
                    
                    List {
                        Section(header:savedPeople.isEmpty ? Text("There are no saved names") : Text("Tap to select names")) {
                            ForEach(savedPeople, id: \.self) { person in
                                SavedNameRow(name: person.name ?? "unkown saved", isSelected: self.selections.contains(person)) {
                                    if self.selections.contains(person) {
                                        selections.removeAll(where: { $0 == person })
                                        HapticGenerator.shared.generateHaptic(.light)
                                    }
                                    else {
                                        if hat.checkDuplicate(person: person) == false {
                                            selections.append(person)
                                            HapticGenerator.shared.generateHaptic(.light)

                                        } else {
                                            duplicateName = person.name!
                                            isShowingAlert.toggle()
                                            HapticGenerator.shared.generateHaptic(.error)
                                        }
                                    }
                                }
                                .deleteDisabled(self.selections.contains(person))
                            }
                            .onDelete(perform: deleteSaved)
                        }
                        
                    }.disabled(savedPeople.isEmpty ? true : false)
              
                }
            }
            .background(Color("backgroundColor"))
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Saved Names")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                    leading:
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                }, trailing:
                    HStack {
                        Image(systemName: "heart.fill")
                            .renderingMode(.template)
                            .foregroundColor(Color("AccentColor"))
                        Text("\(hat.savedNames.count)")
                            .foregroundColor(Color("AccentColor"))
                    }
            )
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Duplicate Name"), message: Text("The name \(duplicateName) is already in the hat."), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: checkEmpty)
            .onChange(of: savedPeople.isEmpty, perform: { value in
                logger.info("onChange: savedPeople.isEmpty = \(savedPeople.isEmpty)")
                withAnimation {
                    isShowingOverlay.toggle()
                }
            })
        }
    }
    
    private func checkEmpty() {
        if savedPeople.isEmpty == true { isShowingOverlay = true }
        else { isShowingOverlay = false }
        logger.info("savedPeople isEmpty = \(savedPeople.isEmpty)")
    }
    
    private func addSelectionsToHat() {
        selections.forEach() { person in
            hat.add(person)
            person.mained = true
            saveContext()
        }
        selections.removeAll()
    }
    
    private func deleteSaved(at offsets: IndexSet) {
        
        for offset in offsets {
            let person = savedPeople[offset]
            logger.info("name: \(person.name!)")
            logger.info("")
            
            if person.saved == true && person.mained == false {
                moc.delete(person)
            } else if person.saved == true {
                person.saved = false
            }
            
            for element in hat.savedNames {
                if element.name == person.name {
                    hat.deleteSaved(element)
                }
            }
        }
        
        saveContext()
        
        logger.info("saved: \(savedPeople.count)")
        logger.info("")
    }
    
    private func delete(_ person: Person) {
        moc.delete(person)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Could not save context \(error)")
        }
    }
    
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView().environmentObject(Hat(names: [], pulledNames: [], savedNames: []))
    }
}

struct SavedNameRow: View {
    var name: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
            HStack {
                Text(name)
                    .font(.title2)
                    .padding(.all, 10)
                
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .foregroundColor(Color("AccentColor"))
                }
            }
        }.foregroundColor(.primary)
            
    }
}
