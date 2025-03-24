import CoreData

extension Task {
    static func fetchAllTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)]
        return request
    }
}
