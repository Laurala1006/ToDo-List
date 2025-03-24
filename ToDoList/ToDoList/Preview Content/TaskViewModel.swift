import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private var managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        fetchTasks()
    }

    func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try managedObjectContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }

    func addTask(title: String) {
        let newTask = Task(context: managedObjectContext)
        newTask.title = title
        newTask.isCompleted = false
        saveContext()
        fetchTasks() // Refresh the tasks list
    }

    func deleteTask(at offsets: IndexSet) {
        offsets.map { tasks[$0] }.forEach(managedObjectContext.delete)
        saveContext()
        fetchTasks() // Refresh the tasks list
    }

    func toggleCompletion(for task: Task) {
        task.isCompleted.toggle()
        saveContext()
        fetchTasks() // Refresh the tasks list
    }

    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
