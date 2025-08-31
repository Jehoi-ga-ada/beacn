//
//  OllamaResponse.swift
//  BEACN
//
//  Created by Jehoiada Wong on 30/08/25.
//

import Foundation
import UIKit

// Structure for the actual disaster response we want
struct DisasterResponse: Decodable {
    let disaster: String
}

// Structure for Ollama's complete response
struct OllamaResponse: Decodable {
    let model: String?
    let response: String
    let done: Bool
    let created_at: String?
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

        // Debug: Print the raw response
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("🔍 Raw Ollama Response: \(rawResponse)")
        }

        // Try to decode as Ollama's complete response structure
        if let ollamaResponse = try? JSONDecoder().decode(OllamaResponse.self, from: data) {
            print("📦 Ollama Response Object: \(ollamaResponse.response)")
            
            // Parse the nested JSON response
            if let responseData = ollamaResponse.response.data(using: .utf8),
               let disasterResponse = try? JSONDecoder().decode(DisasterResponse.self, from: responseData) {
                return disasterResponse.disaster
            }
            
            // If JSON parsing fails, try to extract from string manually
            return extractDisasterFromString(ollamaResponse.response)
        }

        // Fallback: Try direct JSON decode (in case Ollama returns plain JSON)
        if let disasterResponse = try? JSONDecoder().decode(DisasterResponse.self, from: data) {
            return disasterResponse.disaster
        }

        // Last resort: return raw text
        let rawText = String(data: data, encoding: .utf8) ?? "Unknown"
        print("⚠️ Falling back to raw text: \(rawText)")
        return extractDisasterFromString(rawText)
    }
    
    private func extractDisasterFromString(_ text: String) -> String {
        // Try to extract disaster value from JSON-like string
        if let range = text.range(of: "\"disaster\"\\s*:\\s*\"([^\"]+)\"", options: .regularExpression) {
            let match = String(text[range])
            if let valueRange = match.range(of: "\"([^\"]+)\"$", options: .regularExpression) {
                let value = String(match[valueRange])
                return value.replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // If regex fails, return the whole text (your current behavior)
        return text
    }
}
