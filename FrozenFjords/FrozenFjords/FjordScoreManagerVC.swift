//
//  FjordScoreManagerVC.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import Foundation

class FjordScoreManagerVC : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let gameCategories = ["Shadow Jumper", "Starfish Dash", "Undead Archer"]
    
    private let scoreHistoryKey = "scoreHistory"
    private let scoreHistoryKey2 = "scoreHistory2"
    private let scoreHistoryKey3 = "scoreHistory3"
    
    
    static let shared = FjordScoreManagerVC()

    override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "FjordScoreCell", bundle: nil), forCellReuseIdentifier: "FjordScoreCell")
        }
    
    private func getScores(for category: Int) -> [Int] {
            switch category {
            case 0: return FjordScoreManagerVC.shared.getScoreHistory()
            case 1: return FjordScoreManagerVC.shared.getScoreHistory2()
            case 2: return FjordScoreManagerVC.shared.getScoreHistory3()
            default: return []
            }
        }
    // Save a new score to the history
    func saveScore(_ score: Int) {
        var scores = getScoreHistory()
        scores.append(score)
        UserDefaults.standard.set(scores, forKey: scoreHistoryKey)
    }

    // Retrieve the score history
    func getScoreHistory() -> [Int] {
        return UserDefaults.standard.array(forKey: scoreHistoryKey) as? [Int] ?? []
    }

    // Clear score history
    func clearScoreHistory() {
        UserDefaults.standard.removeObject(forKey: scoreHistoryKey)
    }
    
    //MARK:- Game2
    
    func saveScore2(_ score: Int) {
        var scores = getScoreHistory2()
        scores.append(score)
        UserDefaults.standard.set(scores, forKey: scoreHistoryKey2)
    }

    // Retrieve the score history
    func getScoreHistory2() -> [Int] {
        return UserDefaults.standard.array(forKey: scoreHistoryKey2) as? [Int] ?? []
    }

    // Clear score history
    func clearScoreHistory2() {
        UserDefaults.standard.removeObject(forKey: scoreHistoryKey2)
    }
    
    //MARK:- Game3
    
    func saveScore3(_ score: Int) {
        var scores = getScoreHistory2()
        scores.append(score)
        UserDefaults.standard.set(scores, forKey: scoreHistoryKey2)
    }

    // Retrieve the score history
    func getScoreHistory3() -> [Int] {
        return UserDefaults.standard.array(forKey: scoreHistoryKey2) as? [Int] ?? []
    }

    // Clear score history
    func clearScoreHistory3() {
        UserDefaults.standard.removeObject(forKey: scoreHistoryKey2)
    }
    
    private func clearAllScores() {
            clearScoreHistory()
            clearScoreHistory2()
            clearScoreHistory3()
            tableView.reloadData() // Refresh the table view to show updated data
        }
    
    @IBAction func clearAllData(_ sender: UIButton) {
            let alert = UIAlertController(
                title: "Clear All Scores",
                message: "Are you sure you want to delete all scores for all games?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { [weak self] _ in
                self?.clearAllScores()
            }))
            
            present(alert, animated: true, completion: nil)
        }
    
}
extension FjordScoreManagerVC: UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let scores = getScores(for: section)
        return scores.isEmpty ? 1 : scores.count // Show one row for "No scores" if empty.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FjordScoreCell", for: indexPath) as! FjordScoreCell
        let scores = getScores(for: indexPath.section)
        if scores.isEmpty {
            cell.lblscore.text = "No scores available"
        } else {
            cell.lblscore.text = "Score: \(scores[indexPath.row])"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return gameCategories[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
