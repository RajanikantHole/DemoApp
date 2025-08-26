import SwiftUI
import CoreData
import CryptoKit

// MARK: - Crypto Helper
struct CryptoHelper {
    // AES Key (in real app, store securely in Keychain!)
    static let key = SymmetricKey(size: .bits256)
    
    static func encrypt(_ string: String) -> Data? {
        try? AES.GCM.seal(Data(string.utf8), using: key).combined
    }
    
    static func decrypt(_ data: Data) -> String? {
        guard let box = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(box, using: key) else { return nil }
        return String(data: decrypted, encoding: .utf8)
    }
}

// MARK: - Core Data Model
@objc(User)
class UserCoreData: NSManagedObject {
    @NSManaged var emailEncrypted: Data?
}

extension UserCoreData {
    static func fetchAll(_ context: NSManagedObjectContext) -> [UserCoreData] {
        let request: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest() as! NSFetchRequest<UserCoreData>
        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Core Data Stack
class PersistenceController2 {
    static let shared = PersistenceController2()
    let container: NSPersistentContainer
    
    private init() {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "User"
        entity.managedObjectClassName = NSStringFromClass(UserCoreData.self)
        
        let emailAttr = NSAttributeDescription()
        emailAttr.name = "emailEncrypted"
        emailAttr.attributeType = .binaryDataAttributeType
        emailAttr.isOptional = true
        
        entity.properties = [emailAttr]
        model.entities = [entity]
        
        container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load failed: \(error)")
            }
        }
    }
}

// MARK: - SwiftUI App
struct ContentViewCoreData: View {
    @State private var emailInput: String = ""
    @State private var users: [UserCoreData] = []
    let context = PersistenceController2.shared.container.viewContext
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Email", text: $emailInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save Encrypted Email") {
                let user = UserCoreData(context: context)
                user.emailEncrypted = CryptoHelper.encrypt(emailInput)
                try? context.save()
                loadUsers()
            }
            .buttonStyle(.borderedProminent)
            
            List(users, id: \.objectID) { user in
                if let data = user.emailEncrypted,
                   let email = CryptoHelper.decrypt(data) {
                    Text("Decrypted: \(email)")
                }
            }
        }
        .onAppear { loadUsers() }
        .padding()
    }
    
    func loadUsers() {
        users = UserCoreData.fetchAll(context)
    }
}
