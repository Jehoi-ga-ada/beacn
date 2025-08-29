//
//  Config.swift
//  BEACN
//
//  Created by Jehoiada Wong on 28/08/25.
//

import Foundation

struct Config {
    static var dict: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = plist as? [String: Any] else {
            fatalError("❌ Missing or invalid Config.plist")
        }
        return dict
    }()

    static var supabaseURL: URL {
        guard let urlString = dict["SUPABASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("❌ Missing or invalid SUPABASE_URL in Config.plist")
        }
        return url
    }

    static var supabaseServiceRoleKey: String {
        guard let key = dict["SUPABASE_SERVICE_ROLE_KEY"] as? String,
              !key.isEmpty else {
            fatalError("❌ Missing SUPABASE_SERVICE_ROLE_KEY in Config.plist")
        }
        return key
    }
}
