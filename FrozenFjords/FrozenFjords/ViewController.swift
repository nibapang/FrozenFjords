//
//  ViewController.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import UIKit
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viking: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var water: SKSpriteNode!
    var waterFrames: [SKTexture] = []
    var isGameOver = false
    weak var FjordGameVC: FjordGameVC?

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            updateSpawnRate()
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .blue
        physicsWorld.contactDelegate = self

        // **Fix: Load Water Animation Frames Properly**
        waterFrames = (1...22).map { SKTexture(imageNamed: "Water\($0)") }

        // **Fix: Add Animated Water Background**
        water = SKSpriteNode(texture: waterFrames.first)
        water.size = CGSize(width: size.width, height: size.height)
        water.position = CGPoint(x: size.width / 2, y: size.height / 2)
        water.zPosition = -1
        addChild(water)

        let animateWater = SKAction.animate(with: waterFrames, timePerFrame: 0.1, resize: false, restore: false)
        let repeatAnimation = SKAction.repeatForever(animateWater)
        water.run(repeatAnimation)

        // **Fix: Add Viking (Starfish) Character Properly**
        spawnStarfish()

        // **Add Score Label**
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 80, y: size.height - 140)
        addChild(scoreLabel)

        // **Start Spawning Enemies**
        startSpawningEnemies()
    }
    
    func spawnStarfish() {
        viking = SKSpriteNode(imageNamed: "starfish")
        viking.size = CGSize(width: 100, height: 100)
        viking.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // **Fix: Ensure Starfish Has Physics**
        viking.physicsBody = SKPhysicsBody(circleOfRadius: viking.size.width / 2)
        viking.physicsBody?.affectedByGravity = false
        viking.physicsBody?.isDynamic = true
        viking.physicsBody?.categoryBitMask = 1
        viking.physicsBody?.contactTestBitMask = 2
        
        addChild(viking)
    }

    func startSpawningEnemies() {
        removeAction(forKey: "spawningEnemies") // Ensure no duplicate spawn actions
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnMultipleEnemies()
        }
        let delayAction = SKAction.wait(forDuration: 2) // Initial spawn rate
        let sequence = SKAction.sequence([spawnAction, delayAction])
        run(SKAction.repeatForever(sequence), withKey: "spawningEnemies")
    }

    func spawnMultipleEnemies() {
        guard !isGameOver else { return }
        
        let numberOfEnemies = Int.random(in: 1...2) // Spawn 1 to 2 enemies at a time
        
        for _ in 0..<numberOfEnemies {
            spawnEnemy()
        }
    }

    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enmy")
        let randomX = CGFloat.random(in: 0...size.width)
        enemy.size = CGSize(width: 80, height: 80)
        enemy.position = CGPoint(x: randomX, y: size.height)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.velocity = CGVector(dx: 0, dy: -250 - CGFloat(score * 5)) // Increase speed as score increases
        enemy.physicsBody?.categoryBitMask = 2
        addChild(enemy)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver else { return }
        let touchLocation = touch.location(in: self)
        
        // Move Viking to Touch Location
        let moveAction = SKAction.move(to: touchLocation, duration: 0.5)
        viking.run(moveAction)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2) ||
           (contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1) {
            contact.bodyB.node?.removeFromParent()
            score += 1
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // Check if Viking (Starfish) has fallen below the screen
        if viking.position.y < 0 {
            triggerGameOver()
        }

        // Remove enemies that have left the screen
        for node in children {
            if let enemy = node as? SKSpriteNode, enemy.position.y < 0 {
                enemy.removeFromParent()
            }
        }
    }

    func triggerGameOver() {
        isGameOver = true
        
        // Stop enemy spawning
        removeAction(forKey: "spawningEnemies")
        
        // Remove all enemies
        for node in children where node is SKSpriteNode && node != viking && node != water {
            node.removeFromParent()
        }
        
        // Show Game Over Alert
        FjordScoreManagerVC.shared.saveScore(score)
        FjordGameVC?.showGameOverAlert()
    }
    
    func restartGame() {
        isGameOver = false
        score = 0

        // Clear all enemies before restarting
        for node in children where node is SKSpriteNode && node != viking && node != water {
            node.removeFromParent()
        }

        viking.removeFromParent() // Remove old instance
        spawnStarfish() // Respawn properly

        // Restart enemy spawning
        startSpawningEnemies()
    }

    func updateSpawnRate() {
        let newSpawnRate = max(0.5, 1.5 - (Double(score) * 0.05)) // Faster spawn rate as score increases
        
        removeAction(forKey: "spawningEnemies") // Stop current spawn cycle
        
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnMultipleEnemies()
        }
        let delayAction = SKAction.wait(forDuration: newSpawnRate)
        let sequence = SKAction.sequence([spawnAction, delayAction])
        run(SKAction.repeatForever(sequence), withKey: "spawningEnemies")
    }
}

class FjordGameVC: UIViewController {

    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.FjordGameVC = self // Pass reference to GameScene
        skView.presentScene(scene)
    }

    func showGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", message: "Your starfish has fallen!", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.scene.restartGame()
        }
        
        alert.addAction(restartAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
