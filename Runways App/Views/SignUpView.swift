//
//  SignUpView.swift
//  Runways App
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password, confirmPassword
    }

    private var passwordsMatch: Bool {
        password == confirmPassword
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
            && password.count >= 6
            && passwordsMatch
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
                    SecureField("Password (min 6 characters)", text: $password)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .password)
                    SecureField("Confirm password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)
                } header: {
                    Text("Create account")
                } footer: {
                    if let error = auth.authError {
                        Text(error)
                            .foregroundStyle(AppTheme.coral)
                    } else {
                        Text("Use at least 6 characters for your password.")
                    }
                }
                .listRowBackground(AppTheme.cardFill)

                Section {
                    Button("Create account") {
                        focusedField = nil
                        Task {
                            await auth.signUp(email: email, password: password)
                            if auth.isSignedIn {
                                dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!canSubmit)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.skyBlue)
                }
                .listRowBackground(AppTheme.cardFill)
            }
            .scrollContentBackground(.hidden)
            .background(SkySunsetBackground())
            .navigationTitle("Create account")
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
    SignUpView(auth: AuthService())
}
