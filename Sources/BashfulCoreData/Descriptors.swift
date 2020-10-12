import CoreData


public struct FetchDescriptor<Object> {
	public var sortDescriptor: SortDescriptor<Object>
	public var filterDescriptor: FilterDescriptor<Object>

	public var sectionNameKeyPath: String? = nil

	public init(
		sortDescriptor: SortDescriptor<Object>,
		filterDescriptor: FilterDescriptor<Object>,
		sectionNameKeyPath: String? = nil
	) {
		self.sortDescriptor = sortDescriptor
		self.filterDescriptor = filterDescriptor
		self.sectionNameKeyPath = sectionNameKeyPath
	}
}

public extension FetchDescriptor where Object: NSManagedObject {
	var request: NSFetchRequest<Object> {
		let request = Object.fetchRequest() as! NSFetchRequest<Object>
		request.sortDescriptors = sortDescriptor.nsDescriptors
		request.predicate = filterDescriptor.nsPredicate
		return request
	}
}


public struct SortDescriptor<Object> {
	public var sort: (Object, Object) -> Bool
	public var nsDescriptors: [NSSortDescriptor]

	public init(
		nsDescriptors: [NSSortDescriptor] = [],
		sort: @escaping (Object, Object) -> Bool
	) {
		self.nsDescriptors = nsDescriptors
		self.sort = sort
	}
}


public struct FilterDescriptor<Object> {
	public var predicate: (Object) -> Bool
	public var nsPredicate: NSPredicate

	public init(
		nsPredicate: NSPredicate = NSPredicate(value: true),
		predicate: @escaping (Object) -> Bool
	) {
		self.predicate = predicate
		self.nsPredicate = nsPredicate
	}
}
