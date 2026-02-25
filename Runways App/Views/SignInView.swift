//
//  SignInView.swift
//  Runways App
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                } header: {
                    Text("Account")
                } footer: {
                    if let error = auth.authError {
                        Text(error)
                            .foregroundStyle(AppTheme.coral)
                    }
                }
                .listRowBackground(AppTheme.cardFill)

                Section {
                    Button("Sign in") {
                        focusedField = nil
                        Task {
                            await auth.signIn(email: email, password: password)
                            if auth.isSignedIn {
                                dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.skyBlue)
                }
                .listRowBackground(AppTheme.cardFill)
            }
            .scrollContentBackground(.hidden)
            .background(SkySunsetBackground())
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        auth.clearError()
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.skyBlue)
                }
            }
            .tint(AppTheme.skyBlue)
        }
    }
}

#Preview {
    SignInView(auth: AuthService())
}
