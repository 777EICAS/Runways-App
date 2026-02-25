//
//  SupabaseClient.swift
//  Runways App
//

import Foundation
import Supabase

/// Shared Supabase client. Configure SupabaseConfig.url and SupabaseConfig.anonKey before use.
enum SupabaseClient {
    static let shared: Supabase.SupabaseClient = {
        Supabase.SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }()
}
