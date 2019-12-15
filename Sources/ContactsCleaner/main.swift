import Foundation
import Contacts

extension CNContact {
    var descriptionWithRelations: String {
        var identity = self.familyName
        if !identity.isEmpty {
            identity.append(" ")
        }
        identity.append(self.givenName)
        if !identity.isEmpty {
            identity.append(" ")
        }
        identity.append(self.organizationName)
        var description = "\(self.identifier): \(identity)"
        self.contactRelations.forEach { relation in
            let label = relation.label ?? "(undefined)"
            let value = relation.value.name
            description.append("\n  \(label): \(value)")
        }
        return description
    }
}

func hasSonDaughterLabel(_ relation: CNLabeledValue<CNContactRelation>) -> Bool {
    return relation.label == "_$!<Son>!$_" || relation.label == "_$!<Daughter>!$_"
}

func processContacts(from store: CNContactStore, update: Bool) -> Void {
    let keysToFetch = [CNContactIdentifierKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactOrganizationNameKey, CNContactRelationsKey].map { NSString(string: $0) }
    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)

    do {
        var contactsToUpdate = [CNContact]()

        try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, _) in
            if !contact.contactRelations.filter(hasSonDaughterLabel).isEmpty {
                contactsToUpdate.append(contact)
            }
        })

        print("Contacts to update: \(contactsToUpdate.count)")
        
        try contactsToUpdate.forEach { contact in
            print(contact.descriptionWithRelations)
            
            if update {
                let updatedRelations = contact.contactRelations.map { relation -> CNLabeledValue<CNContactRelation> in
                    if hasSonDaughterLabel(relation) {
                        return CNLabeledValue<CNContactRelation>(label: "_$!<Child>!$_", value: relation.value)
                    }
                    else {
                        return relation
                    }
                }
                let updatedContact = contact.mutableCopy() as! CNMutableContact
                updatedContact.contactRelations = updatedRelations
                let saveRequest = CNSaveRequest()
                saveRequest.update(updatedContact);
                try store.execute(saveRequest)
            }
        }
        
        if !contactsToUpdate.isEmpty && !update {
            print("Run \"\(CommandLine.arguments[0]) update\" to update database.")
        }
    }
    catch {
        print("error: \(error)")
    }
}

let update = CommandLine.arguments.count >= 2 && CommandLine.arguments[1] == "update"

let store = CNContactStore()
store.requestAccess(for: .contacts) { allowed, error in
    if allowed {
        processContacts(from: store, update: update)
        exit(0)
    }
    else if let error = error {
        print("permissions error: \(error)")
        exit(1)
    }
    else {
        print("unknown error")
        exit(1)
    }
}

CFRunLoopRun()
