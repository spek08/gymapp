import SwiftUI

struct PhoneInputField: View {
    @Binding var text: String
    let placeholder: String
    
    @State private var formattedText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phone Number")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color("TextSecondary"))
            
            HStack(spacing: 12) {
                // Country code
                Text("🇺🇸 +1")
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .background(Color("SurfaceElevated"))
                    .cornerRadius(10)
                
                // Phone number
                TextField(placeholder, text: $formattedText)
                    .keyboardType(.phonePad)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color("SurfaceElevated"))
                    .cornerRadius(10)
                    .onChange(of: formattedText) { newValue in
                        formattedText = formatPhoneNumber(newValue)
                        text = formattedText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                    }
            }
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let limit = 10
        let limited = String(cleaned.prefix(limit))
        
        if limited.count > 6 {
            return "(\(limited.prefix(3))) \(limited.dropFirst(3).prefix(3))-\(limited.dropFirst(6))"
        } else if limited.count > 3 {
            return "(\(limited.prefix(3))) \(limited.dropFirst(3))"
        } else if !limited.isEmpty {
            return "(\(limited)"
        }
        return limited
    }
}

struct VerificationCodeInput: View {
    @Binding var code: String
    let length: Int
    
    @FocusState private var focusedField: Int?
    @State private var digits: [String]
    
    init(code: Binding<String>, length: Int = 6) {
        self._code = code
        self.length = length
        self._digits = State(initialValue: Array(repeating: "", count: length))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<length, id: \.self) { index in
                TextField("", text: $digits[index])
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 60)
                    .background(Color("SurfaceElevated"))
                    .cornerRadius(12)
                    .focused($focusedField, equals: index)
                    .onChange(of: digits[index]) { newValue in
                        handleInput(at: index, newValue: newValue)
                    }
            }
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    private func handleInput(at index: Int, newValue: String) {
        // Limit to single digit
        if newValue.count > 1 {
            digits[index] = String(newValue.prefix(1))
        }
        
        // Update code string
        code = digits.joined()
        
        // Auto-advance
        if !newValue.isEmpty && index < length - 1 {
            focusedField = index + 1
        }
        
        // Handle backspace on empty
        if newValue.isEmpty && index > 0 {
            focusedField = index - 1
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("TextTertiary"))
            
            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundColor(Color("TextPrimary"))
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("TextTertiary"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("SurfaceElevated"))
        .cornerRadius(12)
    }
}

struct MultilineTextField: View {
    @Binding var text: String
    let placeholder: String
    let maxLength: Int
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(Color("TextPrimary"))
                .padding(12)
                .background(Color("SurfaceElevated"))
                .cornerRadius(12)
                .frame(minHeight: 100)
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.body)
                                .foregroundColor(Color("TextTertiary"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            Text("\(text.count)/\(maxLength)")
                .font(.caption)
                .foregroundColor(text.count > maxLength ? Color("AlertRed") : Color("TextTertiary"))
        }
    }
}

struct GoalSelector: View {
    @Binding var selectedGoals: [User.FitnessGoal]
    let maxSelection: Int
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(User.FitnessGoal.allCases, id: \.self) { goal in
                GoalButton(
                    goal: goal,
                    isSelected: selectedGoals.contains(goal)
                ) {
                    toggleGoal(goal)
                }
            }
        }
    }
    
    private func toggleGoal(_ goal: User.FitnessGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else if selectedGoals.count < maxSelection {
            selectedGoals.append(goal)
        }
    }
}

struct GoalButton: View {
    let goal: User.FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: goal.icon)
                    .font(.system(size: 14))
                Text(goal.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color("PrimaryBlue") : Color("SurfaceElevated"))
            .foregroundColor(isSelected ? .white : Color("TextPrimary"))
            .cornerRadius(20)
        }
    }
}

struct ExperienceLevelPicker: View {
    @Binding var selectedLevel: User.ExperienceLevel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(User.ExperienceLevel.allCases, id: \.self) { level in
                ExperienceLevelButton(
                    level: level,
                    isSelected: selectedLevel == level
                ) {
                    selectedLevel = level
                }
            }
        }
    }
}

struct ExperienceLevelButton: View {
    let level: User.ExperienceLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.headline)
                        .fontWeight(isSelected ? .bold : .semibold)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color("PrimaryBlue"))
                } else {
                    Circle()
                        .stroke(Color("TextTertiary"), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .background(isSelected ? Color("PrimaryBlue").opacity(0.1) : Color("SurfaceElevated"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("PrimaryBlue") : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(Color("TextPrimary"))
    }
}

// MARK: - Previews
#Preview("Input Components") {
    ScrollView {
        VStack(spacing: 24) {
            PhoneInputField(text: .constant("4055550123"), placeholder: "(405) 555-0123")
            VerificationCodeInput(code: .constant("123456"), length: 6)
            SearchBar(text: .constant("Gold's Gym"), placeholder: "Search gyms...", onSubmit: {})
            MultilineTextField(text: .constant(""), placeholder: "Tell us about yourself...", maxLength: 500)
            GoalSelector(selectedGoals: .constant([.buildMuscle]), maxSelection: 5)
            ExperienceLevelPicker(selectedLevel: .constant(.intermediate))
        }
        .padding()
    }
    .background(Color("Background"))
}