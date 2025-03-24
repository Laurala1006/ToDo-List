import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var isPresented: Bool

    @State private var taskTitle = ""
    @State private var selectedCategory = "生活" // 默认类别
    @State private var dueDate = Date()
    @State private var showAlert = false // 控制显示 Alert

    let categories = ["全部", "生活", "學校", "工作"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                }

                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Due Date")) {
                    DatePicker("Select Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationBarTitle("Add New Task", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveTask()
                    showAlert = true // 显示保存成功提示
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Task has been saved successfully!"),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false // 关闭视图
                    }
                )
            }
        }
    }

    private func saveTask() {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.title = taskTitle
        newTask.type = selectedCategory
        newTask.dueDate = stripTime(from: dueDate)

        do {
            try context.save()
        } catch {
            print("Error saving task: \(error)")
        }
    }

    private func stripTime(from date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
}
