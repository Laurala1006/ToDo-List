import SwiftUI

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var tasks: FetchedResults<Task>
    var toggleTaskCompletion: (Task) -> Void

    var body: some View {
        List {
            ForEach(tasks) { task in
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .onTapGesture {
                            toggleTaskCompletion(task)
                        }
                    VStack(alignment: .leading) {
                        Text(task.title ?? "Untitled")
                            .strikethrough(task.isCompleted)
                        Text("Type: \(task.type ?? "Unknown")")
                        Text("Due: \(task.dueDate?.formatted() ?? "No Date")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(PlainListStyle())
    }

    private func deleteTasks(at offsets: IndexSet) {
        offsets.map { tasks[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
