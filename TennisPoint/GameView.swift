//
//  GameView.swift
//  TennisPoint
//
//  Created by furuta on 2025/01/24.
//

import SwiftUI

struct GameTableData: Identifiable {
  var name: String
  var set: Int
  var game: Int
  var point: String
  var id = UUID()
}

struct GameView: View {
  var game: Game
  @Environment(\.dismiss) private var dismiss
  @State var tableData: [GameTableData] =
    [GameTableData(name: "Player1", set: 0, game: 0, point: "0"),
     GameTableData(name: "Player2", set: 0, game: 0, point: "0")]
  
  init(game: Game) {
    self.game = game
  }
  
  func addPoint(for player: Int) {
    game.addPoint(forPlayer: player)
    for i in 0..<2 {
      tableData[i].set = game.getSetScore(for: i + 1)
      tableData[i].game = game.getGameScore(for: i + 1)
      tableData[i].point = game.getPointScore(for: i + 1)
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        HStack(spacing: 20) {
          VStack(spacing: 20) {
            Text(tableData[0].name)
              .font(.title)
              .fontWeight(.bold)
            Text(String(tableData[0].set))
              .font(.largeTitle)
              .fontWeight(.bold)
            Text(String(tableData[0].game))
              .font(.largeTitle)
              .fontWeight(.bold)
            Text(tableData[0].point)
              .font(.largeTitle)
              .fontWeight(.bold)
            Button {
              addPoint(for: 1)
            } label: {
              Text("Point")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
                .background(.green)
                .cornerRadius(10)
            }
          }
          VStack(spacing: 20) {
            Text(tableData[1].name)
              .font(.title)
              .fontWeight(.bold)
            Text(String(tableData[1].set))
              .font(.largeTitle)
              .fontWeight(.bold)
            Text(String(tableData[1].game))
              .font(.largeTitle)
              .fontWeight(.bold)
            Text(tableData[1].point)
              .font(.largeTitle)
              .fontWeight(.bold)
            Button {
              addPoint(for: 2)
            } label: {
              Text("Point")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
                .background(.green)
                .cornerRadius(10)
            }
          }
        }
        Spacer()
        Button {
          game.reset()
          dismiss()
        } label: {
          Text("設定画面に戻る(スコアリセット)")
        }
      }.padding()
    }
  }
}

#Preview {
  GameView(game: Game(totalSets: 1, gamesPerSet: 6, tieBreakEnabled: true, tieBreakAtGame: 6, scoringMode: ScoringMode.traditional))
}
