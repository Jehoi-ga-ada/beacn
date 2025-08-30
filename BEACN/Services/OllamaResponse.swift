import Foundation
import UIKit

struct OllamaResponse: Decodable {
    let disaster: String
}

final class OllamaService {
    static let shared = OllamaService()
    private init() {}

    func analyzeImage(_ image: UIImage) async throws -> String {
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "OllamaService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode photo"])
        }

        let base64Image = jpegData.base64EncodedString()

        let payload: [String: Any] = [
            "model": "gemma3:4b",
            "prompt": """
                What type of disaster is on the image? Respond using JSON with the format of {"disaster": "disaster_type"}
                Reply by picking only one based on these disasters:
                Gas leak or explosion
                Traffic jam
                Protest
                Heavy storm
                Landslide
                Crime nearby
                Heavy rain
                Flood
                Fallen tree
                Accident
                Earthquake
                Fire in nearby building
                Power outage
                No water supply
                Construction
                Building collapse
                Mobil or internet down
                Broken traffic light
                Road closed
            """,
            "format": "json",
            "images": [base64Image],
            "stream": false
        ]

        guard let url = URL(string: "http://192.168.1.8:11434/api/generate"),
              let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            throw NSError(domain: "OllamaService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid request"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let (data, _) = try await URLSession.shared.data(for: request)

        // Try to decode structured response
        if let decoded = try? JSONDecoder().decode(OllamaResponse.self, from: data) {
            return decoded.disaster
        }

        // Fallback: handle raw string that might be JSON text
        if let text = String(data: data, encoding: .utf8),
           let jsonData = text.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(OllamaResponse.self, from: jsonData) {
            return decoded.disaster
        }

        // If all fails, return raw text
        return String(data: data, encoding: .utf8) ?? "Unknown"
    }
}
