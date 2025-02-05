//
//  ContentView.swift
//  TennisPoint
//
//  Created by furuta on 2025/01/24.
//

import SwiftUI

struct ContentView: View {
  @State var selectedSetCount: Int = 1
  @State var selectedGameCount: Int = 6
  @State var selectedTieBreak = 2
  @State var selectedDuece: ScoringMode = ScoringMode.noAdvantage
  
  var body: some View {
    NavigationStack {
      VStack {
        Text("試合のルールを設定してください。")
          .font(.title2)
          .padding(.bottom)
        VStack {
          Text("セット数")
          Picker("Set Count", selection: $selectedSetCount) {
            Text("1").tag(1)
            Text("3").tag(3)
            Text("5").tag(5)
          }
          .pickerStyle(.segmented)
        }
        .padding(.bottom)
        VStack {
          Text("ゲーム数")
          Picker("Game Count", selection: $selectedGameCount) {
            Text("2").tag(2)
            Text("4").tag(4)
            Text("6").tag(6)
            Text("8").tag(8)
          }
          .pickerStyle(.segmented)
        }
        .padding(.bottom)
        VStack {
          Text("タイブレーク")
          Picker("Tie Break", selection: $selectedTieBreak) {
            Text("\(selectedGameCount) - \(selectedGameCount)").tag(0)
            Text("\(selectedGameCount - 1) - \(selectedGameCount - 1)").tag(1)
            Text("なし").tag(2)
          }
          .pickerStyle(.segmented)
        }
        .padding(.bottom)
        VStack {
          Text("デュース")
          Picker("Duece", selection: $selectedDuece) {
            Text("あり").tag(ScoringMode.traditional)
            Text("セミアド").tag(ScoringMode.semiAdvantage)
            Text("ノーアド").tag(ScoringMode.noAdvantage)
          }
          .pickerStyle(.segmented)
        }
        .padding(.bottom)
        NavigationLink {
          GameView(game: Game(totalSets: selectedSetCount, gamesPerSet: selectedGameCount, tieBreakEnabled: selectedTieBreak == 2 ? false : true, tieBreakAtGame: selectedTieBreak == 0 ? 6 : selectedTieBreak == 1 ? 5 : 0, scoringMode: selectedDuece))
            .navigationBarBackButtonHidden(true)
        } label: {
          Text("試合開始")
            .font(.title2)
            .padding()
            .background(.green)
            .foregroundStyle(.white)
            .cornerRadius(10)
        }
        .padding(.top)
        Spacer()
      }
      .padding()
    }
  }
}

#Preview {
  ContentView()
}
