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

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "anthropicApiKey") ?? ""
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard !apiKey.isEmpty else {
            errorText = "Add your Anthropic API key in Settings first."
            return
        }

        messages.append(ChatMessage(role: "user", text: text))
        draft = ""
        isLoading = true
        errorText = nil

        Task {
            do {
                let reply = try await callAPI()
                messages.append(ChatMessage(role: "assistant", text: reply))
            } catch {
                errorText = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func callAPI() async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 1024,
            "messages": messages.map { ["role": $0.role, "content": $0.text] }
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let bodyText = String(data: data, encoding: .utf8) ?? "unknown error"
            throw NSError(domain: "ChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "API error: \(bodyText)"])
        }

        struct Response: Decodable {
            struct Content: Decodable { let type: String; let text: String? }
            let content: [Content]
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.content.compactMap { $0.text }.joined()
    }
}
