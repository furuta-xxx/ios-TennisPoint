//
//  Game.swift
//  TennisPoint
//
//  Created by furuta on 2025/02/05.
//
//  CharGPT o3-mini-highにて作成
import Foundation

/// ゲーム中の得点計算方式
enum ScoringMode {
  case traditional    // 従来のデュース方式（アドバンテージあり）
  case semiAdvantage  // セミアド方式（従来方式と同様の処理）
  case noAdvantage    // ノーアド方式（40-40以降、次のポイントでゲーム決定）
}

/// テニスのスコア計算クラス
class Game {
  
  // MARK: - 設定パラメータ
  
  /// 試合で設定するセット数（例：3ならベスト2セット）
  let totalSets: Int
  /// 各セットで必要なゲーム数（例：6ゲーム先取）
  let gamesPerSet: Int
  /// タイブレークを実施するかどうかのフラグ
  let tieBreakEnabled: Bool
  /// タイブレークを実施するためのゲーム数（例：6を指定すると6-6の場合タイブレーク）
  let tieBreakAtGame: Int
  /// ゲーム内での得点計算方式
  let scoringMode: ScoringMode
  
  // MARK: - 内部状態
  
  /// 各プレイヤーのセット勝利数（index 0: Player1、1: Player2）
  private var setsWon: [Int] = [0, 0]
  /// 現在のセットにおける各プレイヤーのゲーム勝利数
  private var gamesWonCurrentSet: [Int] = [0, 0]
  /// 通常ゲーム中の得点（0: 0, 1:15, 2:30, 3:40 を表す）
  private var gamePoints: [Int] = [0, 0]
  /// タイブレーク中の得点（数値で管理）
  private var tieBreakPoints: [Int] = [0, 0]
  /// 現在のゲームでアドバンテージ状態のプレイヤー（index 0または1）。なければ nil
  private var advantagePlayer: Int? = nil
  /// 現在のセット番号（1セット目からスタート）
  private var currentSet: Int = 1
  /// 試合終了フラグ
  private var matchOver: Bool = false
  /// 内部でタイブレーク中かどうかのフラグ
  private var isTieBreak: Bool = false
  
  // MARK: - 初期化
  
  /// 初期化
  /// - Parameters:
  ///   - totalSets: 試合で設定するセット数（例：3ならベスト2セット）
  ///   - gamesPerSet: 各セットで必要なゲーム数（通常は6）
  ///   - tieBreakEnabled: タイブレークを行うか否か
  ///   - tieBreakAtGame: 例えば6を指定すれば、6-6になった場合にタイブレークを実施する
  ///   - scoringMode: 得点計算方式（従来/セミアド/ノーアド）
  init(totalSets: Int, gamesPerSet: Int, tieBreakEnabled: Bool, tieBreakAtGame: Int, scoringMode: ScoringMode) {
    self.totalSets = totalSets
    self.gamesPerSet = gamesPerSet
    self.tieBreakEnabled = tieBreakEnabled
    self.tieBreakAtGame = tieBreakAtGame
    self.scoringMode = scoringMode
  }
  
  // MARK: - 得点加算処理
  
  /// 指定したプレイヤーの得点を加算する関数
  /// - Parameter player: プレイヤー番号（1または2）
  func addPoint(forPlayer player: Int) {
    let idx = player - 1
    let opp = 1 - idx
    
    // 試合終了後は処理しない
    if matchOver { return }
    
    // タイブレーク中かどうかを判定
    if isTieBreakActive() {
      // タイブレークの場合は、単純な数値加算で、7点以上かつ2点差でゲーム勝利
      tieBreakPoints[idx] += 1
      if tieBreakPoints[idx] >= 7 && (tieBreakPoints[idx] - tieBreakPoints[opp] >= 2) {
        winGame(player: player, isTieBreak: true)
      }
    } else {
      // 通常ゲームの場合、設定された scoringMode に応じた処理を実施
      switch scoringMode {
      case .traditional:
        addPointTraditional(forPlayerIndex: idx)
      case .noAdvantage:
        addPointNoAdv(forPlayerIndex: idx)
      case .semiAdvantage:
        addPointSemiAdvantage(forPlayerIndex: idx)
      }
    }
  }
  
  /// タイブレーク中かどうかを判定する
  private func isTieBreakActive() -> Bool {
    if tieBreakEnabled && gamesWonCurrentSet[0] == tieBreakAtGame && gamesWonCurrentSet[1] == tieBreakAtGame {
      isTieBreak = true
    } else {
      isTieBreak = false
    }
    return isTieBreak
  }
  
  // MARK: - 各方式での得点加算処理
  
  /// 従来のデュース方式で得点を加算する
  private func addPointTraditional(forPlayerIndex idx: Int) {
    let opp = 1 - idx
    
    if gamePoints[idx] < 3 {
      gamePoints[idx] += 1
      if gamePoints[idx] == 4 && gamePoints[opp] <= 2 {
        winGame(player: idx + 1)
      }
    } else if gamePoints[idx] == 3 && gamePoints[opp] < 3 {
      gamePoints[idx] += 1
      winGame(player: idx + 1)
    } else {
      if let adv = advantagePlayer {
        if adv == idx {
          winGame(player: idx + 1)
        } else {
          advantagePlayer = nil
        }
      } else {
        advantagePlayer = idx
      }
    }
  }
  
  /// ノーアド方式で得点を加算する（40-40以降は次のポイントでゲーム勝利）
  private func addPointNoAdv(forPlayerIndex idx: Int) {
    let opp = 1 - idx
    if gamePoints[idx] >= 3 && gamePoints[opp] >= 3 {
      winGame(player: idx + 1)
    } else {
      gamePoints[idx] += 1
      if gamePoints[idx] == 4 {
        winGame(player: idx + 1)
      }
    }
  }
  
  /// セミアド方式で得点を加算する（従来方式と同様の処理）
  private func addPointSemiAdvantage(forPlayerIndex idx: Int) {
    let opp = 1 - idx
    
    if gamePoints[idx] < 3 {
      gamePoints[idx] += 1
      if gamePoints[idx] == 4 && gamePoints[opp] <= 2 {
        winGame(player: idx + 1)
      }
    } else if gamePoints[idx] == 3 && gamePoints[opp] < 3 {
      gamePoints[idx] += 1
      winGame(player: idx + 1)
    } else {
      if let adv = advantagePlayer {
        if adv == idx {
          winGame(player: idx + 1)
        } else {
          advantagePlayer = nil
        }
      } else {
        advantagePlayer = idx
      }
    }
  }
  
  // MARK: - ゲーム／セット／試合勝利の更新処理
  
  /// ゲーム勝利時の処理。タイブレークの場合は isTieBreak を true に指定。
  private func winGame(player: Int, isTieBreak: Bool = false) {
    let idx = player - 1
    gamesWonCurrentSet[idx] += 1
    
    // ゲーム終了時は、通常ゲームの得点、アドバンテージ、タイブレーク得点をリセット
    gamePoints = [0, 0]
    advantagePlayer = nil
    tieBreakPoints = [0, 0]
    self.isTieBreak = false
    
    // １セットマッチの場合
    if totalSets == 1 {
      if hasWonSet(playerIndex: idx) {
        // 1セットマッチではセット数は更新せず、試合終了時のゲーム数を保持する
        matchOver = true
        // gamesWonCurrentSet はそのまま保持（リセットしない）
      }
    } else {
      // 複数セットマッチの場合は通常の処理
      if hasWonSet(playerIndex: idx) {
        setsWon[idx] += 1
        // セット終了時はゲームスコアをリセットし、次のセットへ移行
        gamesWonCurrentSet = [0, 0]
        currentSet += 1
        
        if hasWonMatch(playerIndex: idx) {
          matchOver = true
        }
      }
    }
  }
  
  /// セット勝利判定（設定ゲーム数以上かつ2ゲーム差）
  private func hasWonSet(playerIndex idx: Int) -> Bool {
    let opp = 1 - idx
    return gamesWonCurrentSet[idx] >= gamesPerSet && (gamesWonCurrentSet[idx] - gamesWonCurrentSet[opp] >= 2 || gamesWonCurrentSet[idx] + gamesWonCurrentSet[opp] == tieBreakAtGame * 2 + 1)
  }
  
  /// 試合勝利判定（複数セットマッチの場合、総セット数に応じた勝利条件）
  private func hasWonMatch(playerIndex idx: Int) -> Bool {
    let setsNeeded = totalSets / 2 + 1
    return setsWon[idx] == setsNeeded
  }
  
  // MARK: - スコア取得（個別に取得できる形式）
  
  /// セットスコア（セット勝利数）を取得する
  /// - Parameter player: プレイヤー番号（1または2）
  /// - Returns: セット勝利数（Int）
  func getSetScore(for player: Int) -> Int {
    let idx = player - 1
    return setsWon[idx]
  }
  
  /// ゲームスコア（現在のセット内のゲーム勝利数）を取得する
  /// - Parameter player: プレイヤー番号（1または2）
  /// - Returns: ゲーム勝利数（Int）
  func getGameScore(for player: Int) -> Int {
    let idx = player - 1
    return gamesWonCurrentSet[idx]
  }
  
  /// ポイントスコア（現在のゲーム内の得点）をスコアボード用に取得する
  /// - Parameter player: プレイヤー番号（1または2）
  /// - Returns: 得点（例："0", "15", "30", "40", "Ad"、タイブレークの場合は数値文字列）
  func getPointScore(for player: Int) -> String {
    let idx = player - 1
    
    // タイブレーク中の場合はタイブレーク得点を返す
    if isTieBreakActive() {
      return "\(tieBreakPoints[idx])"
    }
    
    let pointNames = ["0", "15", "30", "40"]
    if gamePoints[0] >= 3 && gamePoints[1] >= 3 {
      if let adv = advantagePlayer, adv == idx {
        return "Ad"
      } else {
        return "40"
      }
    } else {
      let pts = gamePoints[idx]
      if pts < pointNames.count {
        return pointNames[pts]
      } else {
        return "\(pts)"
      }
    }
  }
  
  // MARK: - リセット処理
  
  /// 試合の状態を初期状態にリセットする関数
  func reset() {
    setsWon = [0, 0]
    gamesWonCurrentSet = [0, 0]
    gamePoints = [0, 0]
    tieBreakPoints = [0, 0]
    advantagePlayer = nil
    currentSet = 1
    matchOver = false
    isTieBreak = false
  }
}

