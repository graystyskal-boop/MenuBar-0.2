import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let text: String
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draft: String = ""
    @Published var isLoading = false
    @Published var errorText: String?

    private var modelName: String {
        let stored = UserDefaults.standard.string(forKey: "ollamaModelName") ?? ""
        return stored.isEmpty ? "llama3.2" : stored
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(ChatMessage(role: "user", text: text))
        draft = ""
        isLoading = true
        errorText = nil

        Task {
            do {
                let reply = try await callOllama()
                messages.append(ChatMessage(role: "assistant", text: reply))
            } catch {
                errorText = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func callOllama() async throws -> String {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:11434/api/chat")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": modelName,
            "stream": false,
            "messages": messages.map { ["role": $0.role, "content": $0.text] }
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "ChatViewModel", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "No response from Ollama. Is it running? Try 'ollama serve' in Terminal."
            ])
        }
        guard http.statusCode == 200 else {
            let bodyText = String(data: data, encoding: .utf8) ?? "unknown error"
            throw NSError(domain: "ChatViewModel", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Ollama error (\(http.statusCode)): \(bodyText)"
            ])
        }

        struct OllamaResponse: Decodable {
            struct Message: Decodable { let role: String; let content: String }
            let message: Message
        }
        let decoded = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return decoded.message.content
    }
}
