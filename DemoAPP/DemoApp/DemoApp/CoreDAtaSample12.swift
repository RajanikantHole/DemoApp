import SwiftUI
import CoreData

// MARK: - Core Data Stack with SQLCipher
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "EncryptedModel")

        let storeURL = URL(fileURLWithPath: "/tmp/EncryptedModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)

        // 🔒 SQLCipher Encryption Options
        description.setOption("myStrongPassword" as NSObject, forKey: "PRAGMA key")
        description.setOption("DELETE" as NSObject, forKey: "PRAGMA cipher_memory_security")

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}

// MARK: - Core Data Entity (Encrypted Note)
extension Note {
    static func create(text: String, context: NSManagedObjectContext) {
        let note = Note(context: context)
        note.id = UUID()
        note.text = text
        try? context.save()
    }
}

// MARK: - SwiftUI View
struct ContentViewCore: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Note.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Note.text, ascending: true)])
    private var notes: FetchedResults<Note>

    @State private var inputText = ""

    var body: some View {
        VStack {
            TextField("Enter secure note", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save Note") {
                Note.create(text: inputText, context: context)
                inputText = ""
            }
            .padding()

            List(notes, id: \.id) { note in
                Text(note.text ?? "Empty")
            }
        }
        .padding()
    }
}

// MARK: - App Entry Point
//@main
//struct EncryptedCoreDataApp: App {
//    let persistence = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            ContentViewCore()
//                .environment(\.managedObjectContext, persistence.container.viewContext)
//        }
//    }
//}

// MARK: - Core Data Model Class
// ✅ Create a Core Data entity `Note` with fields: id(UUID), text(String)
public class Note: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
}
