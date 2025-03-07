//
//  FjordsGameVC2.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import UIKit
import SpriteKit
import GameplayKit

class GameScene2: SKScene, SKPhysicsContactDelegate {
    
    var ninja: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    weak var FjordGameVC: FjordsGameVC2?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        // Set Background Image
        let background = SKSpriteNode(imageNamed: "ic_gamebg2")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        // Add Ninja
        ninja = SKSpriteNode(imageNamed: "ninja")
        ninja.size = CGSize(width: 70, height: 70)
        ninja.position = CGPoint(x: size.width / 2, y: size.height / 2)
        setupNinjaPhysics()
        addChild(ninja)
        
        // Add Score Label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 100, y: size.height - 140)
        addChild(scoreLabel)
        
        // Start Spawning Platforms
        startSpawningPlatforms()
        
        // Score Timer
        let scoreAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                self?.score += 1
            }
        ]))
        run(scoreAction)
    }
    
    func setupNinjaPhysics() {
        ninja.physicsBody = SKPhysicsBody(circleOfRadius: ninja.size.width / 2)
        ninja.physicsBody?.affectedByGravity = true
        ninja.physicsBody?.isDynamic = true
        ninja.physicsBody?.categoryBitMask = 1
        ninja.physicsBody?.contactTestBitMask = 2
        ninja.physicsBody?.restitution = 1.0
    }
    
    func startSpawningPlatforms() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnPlatform()
        }
        let delayAction = SKAction.wait(forDuration: 1.2)
        let sequence = SKAction.sequence([spawnAction, delayAction])
        run(SKAction.repeatForever(sequence), withKey: "spawningPlatforms")
    }
    
    func spawnPlatform() {
        guard !isGameOver else { return }
        
        let platformWidth: CGFloat = 100
        let platformHeight: CGFloat = 10
        
        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight))
        platform.fillColor = .black
        platform.strokeColor = .white
        platform.lineWidth = 2
        
        let randomX = CGFloat.random(in: 0...(size.width - platformWidth))
        platform.position = CGPoint(x: randomX, y: -50)
        
        // Add physics to the platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = 2
        addChild(platform)
        
        // Move platform upwards and remove it when off-screen
        let moveUp = SKAction.moveBy(x: 0, y: size.height + 50, duration: 4.0)
        let remove = SKAction.removeFromParent()
        platform.run(SKAction.sequence([moveUp, remove]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver else { return }
        let touchLocation = touch.location(in: self)
        
        // Move ninja left/right only
        let moveAction = SKAction.moveTo(x: touchLocation.x, duration: 0.2)
        ninja.run(moveAction)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        if ninja.position.y < 0 {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        isGameOver = true
        
        // Stop platform spawning
        removeAction(forKey: "spawningPlatforms")
        
        // Remove all platforms
        for node in children where node is SKShapeNode {
            node.removeFromParent()
        }
        
        // Show Game Over Alert
        FjordScoreManagerVC.shared.saveScore2(score)
        FjordGameVC?.showGameOverAlert()
    }
    
    func restartGame() {
        isGameOver = false
        score = 0
        
        // Reset ninja position and physics
        ninja.position = CGPoint(x: size.width / 2, y: size.height / 2)
        setupNinjaPhysics()
        
        // Restart platform spawning
        startSpawningPlatforms()
        ninja.physicsBody?.velocity = CGVector(dx: 0, dy: 400)
    }
}

class FjordsGameVC2: UIViewController {

    var scene: GameScene2!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        scene = GameScene2(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.FjordGameVC = self // Pass reference to GameScene
        skView.presentScene(scene)
    }

    func showGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", message: "You fell!", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.scene.restartGame()
        }
        
        alert.addAction(restartAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
