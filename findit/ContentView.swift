//
//  ContentView.swift
//  findit
//
//  Created by user271029 on 12/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var targetNumber = Int.random(in: 100...999)
    @State private var currentGuess = ""
    @State private var guesses: [(number: String, result: String)] = []
    @State private var gameOver = false
    @State private var showWinAlert = false
    @State private var showLoseAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Find the Number")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Enter a 3-digit number")
                .font(.subheadline)
            
            TextField("Your guess", text: $currentGuess)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 200)
                .multilineTextAlignment(.center)
            
            Button("Submit Guess") {
                submitGuess()
            }
            .disabled(currentGuess.count != 3 || !currentGuess.allSatisfy { $0.isNumber })
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(guesses, id: \.number) { guess in
                        HStack {
                            Text(guess.number)
                                .frame(width: 100)
                            Text(guess.result)
                                .frame(width: 200)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            if gameOver {
                Text("The number was \(targetNumber)")
                    .font(.headline)
            }
        }
        .padding()
        .alert("Congratulations!", isPresented: $showWinAlert) {
            Button("Play Again", action: resetGame)
        } message: {
            Text("You found the number in \(guesses.count) tries!")
        }
        .alert("Game Over", isPresented: $showLoseAlert) {
            Button("Try Again", action: resetGame)
        } message: {
            Text("The number was \(targetNumber)")
        }
    }
    
    private func submitGuess() {
        guard let guessNumber = Int(currentGuess), (100...999).contains(guessNumber) else { return }
        
        let result = checkGuess(guessNumber)
        guesses.insert((currentGuess, result), at: 0)
        
        if result == "+3" {
            showWinAlert = true
            gameOver = true
        } else if guesses.count >= 7 {
            showLoseAlert = true
            gameOver = true
        }
        
        currentGuess = ""
    }
    
    private func checkGuess(_ guess: Int) -> String {
        let targetDigits = Array(String(targetNumber))
        let guessDigits = Array(String(guess))
        
        var correctPosition = 0
        var incorrectPosition = 0
        
        var usedTargetIndices = Set<Int>()
        var usedGuessIndices = Set<Int>()
        
        // Check correct positions first
        for i in 0..<3 {
            if guessDigits[i] == targetDigits[i] {
                correctPosition += 1
                usedTargetIndices.insert(i)
                usedGuessIndices.insert(i)
            }
        }
        
        // Check incorrect positions
        for i in 0..<3 where !usedGuessIndices.contains(i) {
            for j in 0..<3 where !usedTargetIndices.contains(j) {
                if i != j && guessDigits[i] == targetDigits[j] {
                    incorrectPosition += 1
                    usedTargetIndices.insert(j)
                    usedGuessIndices.insert(i)
                    break
                }
            }
        }
        
        if correctPosition == 3 {
            return "+3"
        }
        
        var result = ""
        if correctPosition > 0 {
            result += "+\(correctPosition) "
        }
        if incorrectPosition > 0 {
            result += "-\(incorrectPosition)"
        }
        return result.isEmpty ? "0" : result.trimmingCharacters(in: .whitespaces)
    }
    
    private func resetGame() {
        targetNumber = Int.random(in: 100...999)
        currentGuess = ""
        guesses.removeAll()
        gameOver = false
    }
}

#Preview {
    ContentView()
}
