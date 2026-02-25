//
//  SupabaseConfig.swift
//  Runways App
//

import Foundation

/// Supabase project URL and anon key. Loaded from SupabaseConfig.plist in the app bundle (so it works every launch).
enum SupabaseConfig {
    /// Project URL from Supabase Dashboard → Project Settings → API.
    static var url: URL {
        guard let s = urlString, !s.isEmpty, let u = URL(string: s) else {
            return URL(string: "https://placeholder.supabase.co")!
        }
        return u
    }

    /// Anon public key from Supabase Dashboard → Project Settings → API.
    static var anonKey: String {
        anonKeyString ?? ""
    }

    /// Load from SupabaseConfig.plist in the bundle first (reliable when app is launched from home screen), then Info.plist, then env.
    private static var urlString: String? {
        if let s = plistConfig?["SUPABASE_URL"] as? String, !s.isEmpty { return s }
        return Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
            ?? ProcessInfo.processInfo.environment["SUPABASE_URL"]
    }

    private static var anonKeyString: String? {
        if let s = plistConfig?["SUPABASE_ANON_KEY"] as? String, !s.isEmpty { return s }
        return Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
            ?? ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
    }

    /// SupabaseConfig.plist in the app bundle (copy in Xcode so it's included in the build).
    private static var plistConfig: [String: Any]? {
        guard let url = Bundle.main.url(forResource: "SupabaseConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return dict
    }

    static var isConfigured: Bool {
        let u = urlString ?? ""
        let k = anonKeyString ?? ""
        return !u.isEmpty && !k.isEmpty && u != "https://placeholder.supabase.co"
    }
}
