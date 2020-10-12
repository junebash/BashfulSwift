import CoreData


public class CoreDataStack {
	public enum StoreType {
		case persistent
		case inMemory
	}

	public let container: NSPersistentContainer

	public var mainContext: NSManagedObjectContext { container.viewContext }

	public init(
		name: String,
		storeType: StoreType = .persistent,
		contextMergesFromParent: Bool = true,
		completion: @escaping (Error?) -> Void = {
			if let error = $0 {
				assertionFailure("Failed to load persistent stores: \(error)")
			}
		}
	) {
		self.container = NSPersistentContainer(name: name)
		container.loadPersistentStores { completion($1) }
		container.viewContext.automaticallyMergesChangesFromParent
			= contextMergesFromParent
	}

	public func save(in context: NSManagedObjectContext? = nil) throws {
		let thisContext = context ?? mainContext
		var saveError: Error?
		thisContext.performAndWait {
			do {
				try thisContext.save()
			} catch {
				saveError = error
			}
		}
		if let error = saveError { throw error }
	}

	public func fetchedResultsController<Object: NSManagedObject>(
		forFetchDescriptor fetchDescriptor: FetchDescriptor<Object>,
		context: NSManagedObjectContext? = nil,
		cacheName: String? = nil
	) -> NSFetchedResultsController<Object> {
		return NSFetchedResultsController(
			fetchRequest: fetchDescriptor.request,
			managedObjectContext: context ?? mainContext,
			sectionNameKeyPath: fetchDescriptor.sectionNameKeyPath,
			cacheName: cacheName)
	}
}
