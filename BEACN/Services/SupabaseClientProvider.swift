//
//  SupabaseClientProvider.swift
//  BEACN
//
//  Created by Jehoiada Wong on 28/08/25.
//

import Supabase

struct AppLogger: SupabaseLogger {
  func log(message: SupabaseLogMessage) {
    print("[Supabase] \(message.description)")
  }
}

let supabase = SupabaseClient(
    supabaseURL: Config.supabaseURL,
    supabaseKey: Config.supabaseServiceRoleKey,
    options: SupabaseClientOptions(
        global: SupabaseClientOptions.GlobalOptions(
            logger: AppLogger()
        )
    )
)
