import Supabase
import Foundation

enum SupabaseConfig {
    // Fill these in with your own Supabase project's URL and anon (public) key.
    // Dashboard: Project Settings -> API.
    static let projectURL = URL(string: "https://YOUR-PROJECT-REF.supabase.co")!
    static let anonKey = "YOUR-SUPABASE-ANON-KEY"

    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey
    )
}
