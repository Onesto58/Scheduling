import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WatchViewModel.shared

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(viewModel.routineName).font(.headline).foregroundColor(.blue)) {
                    if viewModel.tasks.isEmpty && viewModel.bedtimeTasks.isEmpty {
                        Text("Sincronizza una routine dal telefono")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(0..<viewModel.tasks.count, id: \.self) { index in
                            TaskRow(task: viewModel.tasks[index], color: .blue)
                        }
                        
                        if !viewModel.bedtimeTasks.isEmpty {
                            Section(header: Text("SERALE").font(.caption).foregroundColor(.indigo)) {
                                ForEach(0..<viewModel.bedtimeTasks.count, id: \.self) { index in
                                    TaskRow(task: viewModel.bedtimeTasks[index], color: .indigo)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scheduling")
        }
    }
}

struct TaskRow: View {
    let task: [String: Any]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formatTime(task["startTime"] as? String))
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(task["duration"] as? Int ?? 0) min")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Text(task["title"] as? String ?? "Senza titolo")
                .font(.system(size: 15))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
    
    func formatTime(_ isoString: String?) -> String {
        guard let isoString = isoString else { return "--:--" }
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let outFormatter = DateFormatter()
            outFormatter.dateFormat = "HH:mm"
            return outFormatter.string(from: date)
        }
        return "--:--"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
