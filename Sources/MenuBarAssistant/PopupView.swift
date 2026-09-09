import SwiftUI

struct PopupView: View {
    @ObservedObject var viewModel: ChatViewModel
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Assistant")
                    .font(.headline)
                Spacer()
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }
            .padding(10)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.role == "user" { Spacer() }
                            Text(message.text)
                                .padding(8)
                                .background(message.role == "user" ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
                                .cornerRadius(8)
                            if message.role != "user" { Spacer() }
                        }
                    }
                    if viewModel.isLoading {
                        ProgressView().padding(.top, 4)
                    }
                    if let errorText = viewModel.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(10)
            }

            Divider()

            HStack {
                TextField("Ask something…", text: $viewModel.draft, onCommit: viewModel.send)
                    .textFieldStyle(.roundedBorder)
                Button("Send", action: viewModel.send)
                    .keyboardShortcut(.return, modifiers: [])
            }
            .padding(10)
        }
        .frame(width: 340, height: 420)
    }
}
