import SwiftUI

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var isPresented: Bool

    @ObservedObject var task: Task

    @State private var showAlert = false // 控制显示 Alert
    let categories = ["全部", "生活", "學校", "工作"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: Binding(
                        get: { task.title ?? "" },
                        set: { task.title = $0 }
                    ))
                }

                Section(header: Text("Category")) {
                    Picker("Select Category", selection: Binding(
                        get: { task.type ?? "生活" },
                        set: { task.type = $0 }
                    )) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Due Date")) {
                    DatePicker("Select Date", selection: Binding(
                        get: { task.dueDate ?? Date() },
                        set: { task.dueDate = stripTime(from: $0) }
                    ), displayedComponents: .date)
                }
            }
            .navigationBarTitle("Edit Task", displayMode: .inline)
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
                    message: Text("Task has been updated successfully!"),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false // 关闭编辑视图
                    }
                )
            }
        }
    }

    private func saveTask() {
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
