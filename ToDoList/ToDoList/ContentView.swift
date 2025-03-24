import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)]
    ) private var tasks: FetchedResults<Task>

    @State private var showingAddTaskView = false

    // 任務類別篩選
    @State private var selectedCategoryFilter = "全部"
    let categories = ["全部", "生活", "學校", "工作"]

    // 任務狀態篩選
    @State private var selectedStatusFilter = "全部"
    let statuses = ["全部", "完成", "未完成", "已過期"]
    
    // 篩選後的任務列表
    @State private var editingTask: Task? // 用於存儲當前正在編輯的任務
    @State private var showingEditTaskView = false
    @State private var showOnlyToday = false // 新增 Today 篩選狀態

    var body: some View {
        NavigationView {
            VStack {
                // 篩選器區域
                HStack {
                    // 狀態篩選下拉選單
                    Menu {
                        Picker("狀態", selection: $selectedStatusFilter) {
                            ForEach(statuses, id: \.self) { status in
                                Text(status).tag(status)
                            }
                        }
                    } label: {
                        HStack {
                            Text("狀態：\(selectedStatusFilter)")
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        //.frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // 類別篩選下拉選單
                    Menu {
                        Picker("類別", selection: $selectedCategoryFilter) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    } label: {
                        HStack {
                            Text("類別：\(selectedCategoryFilter)")
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        //.frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()

                List {
                    ForEach(filteredTasks()) { task in
                        HStack {
                            // Checkbox
                            Button(action: {
                                toggleTaskCompletion(task)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            VStack(alignment: .leading) {
                                Text(task.title ?? "Untitled")
                                    .strikethrough(task.isCompleted, color: .black)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                    .font(.headline)

                                Text(task.type ?? "No Type")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "No Date")
                                    .font(.footnote)
                                    .foregroundColor(task.isCompleted ? .gray : .secondary)
                            }

                            Spacer()

                            // 編輯按鈕
                            Button(action: {
                                editingTask = task
                                showingEditTaskView = true
                            }) {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
                .sheet(item: $editingTask) { task in
                    EditTaskView(isPresented: $showingEditTaskView, task: task)
                }

                // 新增任務按鈕
                Button(action: {
                    showingAddTaskView = true
                }) {
                    Text("Add Task")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .sheet(isPresented: $showingAddTaskView) {
                    AddTaskView(isPresented: $showingAddTaskView)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: Button("Today") {
                            showOnlyToday.toggle()})
        }
        
    }

    // 其餘函數保持不變
    private func filteredTasks() -> [Task] {
        var filteredTasks = tasks.map { $0 }

            // 類別篩選
            if selectedCategoryFilter != "全部" {
                filteredTasks = filteredTasks.filter { $0.type == selectedCategoryFilter }
            }

            // 狀態篩選
            if selectedStatusFilter == "完成" {
                filteredTasks = filteredTasks.filter { $0.isCompleted }
            } else if selectedStatusFilter == "未完成" {
                filteredTasks = filteredTasks.filter { !$0.isCompleted }
            } else if selectedStatusFilter == "已過期" {
                let todayStart = Calendar.current.startOfDay(for: Date()) // 今天的开始时间
                filteredTasks = filteredTasks.filter {
                    let dueDate = $0.dueDate ?? Date()
                    return dueDate < todayStart && !$0.isCompleted
                }
            }
        // Today 篩選
                if showOnlyToday {
                    let today = Calendar.current.startOfDay(for: Date())
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                    filteredTasks = filteredTasks.filter { ($0.dueDate ?? Date()) >= today && ($0.dueDate ?? Date()) < tomorrow }
                }

        return filteredTasks
    }


    private func toggleTaskCompletion(_ task: Task) {
        task.isCompleted.toggle()
        saveContext()
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
    
    private func formatDate(_ date: Date?) -> String {
            guard let date = date else { return "No Date" }
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
