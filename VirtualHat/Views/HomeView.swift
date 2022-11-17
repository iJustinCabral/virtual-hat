//
//  HomeView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI
import OSLog

enum ActiveSheet: Hashable, Identifiable {
    case add, saved, tutorial
    
    var id: Int {
        return self.hashValue
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Person.entity(), sortDescriptors: [], predicate: NSPredicate(format: "mained == true")) var people: FetchedResults<Person>
    @FetchRequest(entity: Person.entity(), sortDescriptors: [], predicate: NSPredicate(format: "saved == true")) var savedPeople: FetchedResults<Person>
    @FetchRequest(entity: Person.entity(), sortDescriptors: [], predicate: NSPredicate(format: "pulled == true")) var pulledPeople: FetchedResults<Person>

    @State private var didAppear: Bool = false
    @State private var isPressed = false
    @State private var isEmptying = false
    @State private var isCountViewHidden = false
    @State private var isShowingWelcome = false
    @State private var isShowingOverlay = false
    @State private var activeSheet: ActiveSheet? = nil
    @State private var name = ""
    @State private var scrollTarget: String?
    @State private var deleteScrollTarget: UUID?

    
    @StateObject private var hat = Hat(names: [], pulledNames: [], savedNames: [])
    
    let row = [GridItem(.fixed(300))]
    let logger = Logger()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                
                if isShowingOverlay {
                    OverlayView(message: "The Hat is Empty", subMessage: "Add names to the hat.")
                }
                
                VStack {
                    CountView(count: hat.count)
                        .offset(y: 6)
                    
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                                                
                        ScrollViewReader { proxy in
                            LazyHGrid(rows: row, alignment: .center) {
                                ForEach(hat.pulledNames, id: \.self) { person in
                                    Card(name: person.name ?? "unkown name")
                                        .padding(.horizontal, 10)
                                        .id(person.name!)
                                }
                            }
                            .onChange(of: scrollTarget) { target in
                                if let target = target {
                                    scrollTarget = nil
                                    withAnimation {
                                        proxy.scrollTo(target, anchor: .center)
                                    }
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity)
                        
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            HapticGenerator.shared.generateHaptic(.medium)
                            pickRandomPerson()
                            hat.pulledNames.forEach { person in
                               scrollTarget = person.name!
                            }
                       }
                    }) {
                        Image("hat")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 140, height: 140, alignment: .center)
                            .scaleEffect(y:isPressed ? 0.5 : 1.0, anchor: .center)
                            .animation(Animation.spring())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(hat.isEmpty ? true : false)
                    .opacity(hat.isEmpty ? 0.5 : 1)
                    
                }
                .navigationTitle("Virtual Hat")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                    Button(action: { activeSheet = .tutorial }) {
                        Image(systemName: "questionmark")
                    }
                        .padding(.all, 10),
                                    trailing:
                    Button(action: { activeSheet = .saved }) {
                        Image(systemName: "heart.fill")
                    }
                        .padding(.all, 10)
                        .disabled(hat.pulledNames.count >= 1 ? true : false )
                )
                .onChange(of: empty(), perform: { value in
                    logger.info("onChange empty: == \(empty())")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isShowingOverlay.toggle()
                        }
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            activeSheet = .add
                        }) {
                            HStack {
                                Text("Add Names")
                            }
                        }.disabled(hat.pulledNames.count >= 1 ? true : false)
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                                isEmptying = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Empty")
                            }
                        }.disabled(hat.count == 0 && hat.pulledNames.count == 0 ? true : false)
                        
                    }

                }
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .add:
                        AddView()
                            .environment(\.managedObjectContext, self.moc)
                            .environmentObject(hat)
                    case .saved:
                        SavedView()
                            .environment(\.managedObjectContext, self.moc)
                            .environmentObject(hat)
                    case .tutorial:
                        WelcomeView()
                    }
                }
                .alert(isPresented: $isEmptying) {
                    Alert(title: Text("Empty The Hat"), message: Text("Are you sure you want to empty the hat?"), primaryButton: .default(Text("Yes")) {
                        withAnimation {
                            emptyTheHat()
                            HapticGenerator.shared.generateHaptic(.error)
                        }
                        isEmptying = false
                    }, secondaryButton: .cancel({
                        isEmptying = false
                    }))
                }
                .onAppear(perform: checkFirstLaunch)
                .onAppear(perform: loadData)
            }
        }
    }
    
    private func empty() -> Bool {
        if people.isEmpty && pulledPeople.isEmpty {
            logger.info("empty = true")
            return true
        } else {
            logger.info("empty = false")
            return false
        }
    }
    
    private func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "didLaunchBefore") {
            UserDefaults.standard.setValue(true, forKey: "didLaunchBefore")
            activeSheet = .tutorial
        }
    }
    
    private func checkEmpty() {
        if empty() == true { isShowingOverlay = true }
        else { isShowingOverlay = false }
    }
    
    private func pickRandomPerson() {

        guard let person = hat.names.randomElement() else { return }
        for (index, element) in hat.names.enumerated() {
            if element.name == person.name {
                hat.names.remove(at: Int(index))
            }
        }
        
        person.mained = false
        person.pulled = true
        saveContext()
        hat.pulledNames.append(person)

    }
    
    private func emptyTheHat() {
        
        hat.emptyTheHat()
        
        people.forEach { person in
            person.mained = false
            if person.saved == false {
                moc.delete(person)
            }
        }
        
        pulledPeople.forEach { person in
            person.pulled = false
            if person.saved == false {
                moc.delete(person)
            }
        }
        
        saveContext()
        
        logger.info("people: \(people.count)")
        logger.info("pulled: \(pulledPeople.count)")
        logger.info("saved: \(savedPeople.count)")
        logger.info("")
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Could not save context \(error)")
        }
    }
    
    private func loadData() {
        
        //FIXME: This is a hack until apple solves the problem of onAppear loading twice
        if didAppear == false {
            people.forEach { person in
                hat.add(person)
            }
            savedPeople.forEach { person in
                hat.save(person)
            }
            pulledPeople.forEach { person in
                hat.pulledNames.append(person)
            }
            
            logger.info("people: \(people.count)")
            logger.info("pulled: \(pulledPeople.count)")
            logger.info("saved: \(savedPeople.count)")
            logger.info("")
            
        }
        defer { checkEmpty() }
        didAppear = true
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(x: configuration.isPressed ? 0.5 : 1)
    }
}
