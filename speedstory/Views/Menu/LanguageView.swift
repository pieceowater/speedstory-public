//
//  LanguageView.swift
//  speedstory
//
//  Created by yury mid on 27.05.2023.
//

import SwiftUI

struct LanguageView: View {
    @EnvironmentObject var userSettings: UserSettingsManager
    @State private var showAlert = false
    
    let languages = [
        Language(icon: "🇷🇺", name: "Русский", code: "ru"),
        Language(icon: "🇺🇸", name: "English", code: "en")
    ]
    
    var body: some View {
        List(languages, id: \.name) { language in
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                userSettings.setLanguage(language)
                showAlert = true
            }) {
                LanguageRow(language: language)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("menu_settings_language")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("alert_apprestart"),
                message: Text("alert_apprestart_msg"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}


struct LanguageRow: View {
    let language: Language
    
    var body: some View {
        HStack {
            Text(language.icon)
                .padding(10)
                .background(.ultraThinMaterial)
                .cornerRadius(100)
            Text(language.name)
                .font(.headline)
        }
    }
}




struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageView()
    }
}
