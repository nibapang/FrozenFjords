//
//  FjordsGameVC4.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import UIKit
import SpriteKit
import GameplayKit

class GameScene4: SKScene, SKPhysicsContactDelegate {
    
    var archer: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    
    let archerCategory: UInt32 = 1
    let zombieCategory: UInt32 = 2
    let arrowCategory: UInt32 = 4
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "ic_bg3")
        background.zPosition = -1
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let widthRatio = size.width / background.size.width
        let heightRatio = size.height / background.size.height
        let scale = max(widthRatio, heightRatio)
        background.setScale(scale)
        
        addChild(background)
        
        archer = SKSpriteNode(imageNamed: "ic_archer")
        archer.size = CGSize(width: 80, height: 120)
        archer.position = CGPoint(x: size.width / 2, y: 100)
        addChild(archer)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 140)
        addChild(scoreLabel)
        
        startSpawningZombies()
    }
    
    func startSpawningZombies() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnZombie()
        }
        let delay = SKAction.wait(forDuration: 2.0)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func spawnZombie() {
        guard !isGameOver else { return }
        
        let zombie = SKSpriteNode(imageNamed: "zombie")
        zombie.size = CGSize(width: 70, height: 100)
        zombie.zRotation = -.pi / 2
        zombie.position = CGPoint(x: CGFloat.random(in: 100...size.width - 100), y: size.height)
        zombie.physicsBody = SKPhysicsBody(rectangleOf: zombie.size)
        zombie.physicsBody?.affectedByGravity = false
        zombie.physicsBody?.isDynamic = true
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.collisionBitMask = 0
        zombie.physicsBody?.contactTestBitMask = arrowCategory
        addChild(zombie)
        
        let moveDown = SKAction.moveBy(x: 0, y: -size.height, duration: 4.0)
        let remove = SKAction.run { [weak self] in
            self?.triggerGameOver()
        }
        zombie.run(SKAction.sequence([moveDown, remove]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let newX = max(40, min(size.width - 40, touchLocation.x))
            archer.position.x = newX
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        shootArrow()
    }
    
    func shootArrow() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.size = CGSize(width: 10, height: 120)
        arrow.position = CGPoint(x: archer.position.x, y: archer.position.y + 60)
        arrow.zRotation = .pi / 2
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.isDynamic = true
        arrow.physicsBody?.categoryBitMask = arrowCategory
        arrow.physicsBody?.contactTestBitMask = zombieCategory
        arrow.physicsBody?.collisionBitMask = 0
        addChild(arrow)
        
        let moveUp = SKAction.moveBy(x: 0, y: size.height, duration: 1.0)
        let remove = SKAction.removeFromParent()
        arrow.run(SKAction.sequence([moveUp, remove]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        if (bodyA == arrowCategory && bodyB == zombieCategory) || (bodyA == zombieCategory && bodyB == arrowCategory) {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            score += 1
        }
    }
    
    func triggerGameOver() {
        isGameOver = true
        removeAllActions()
        
        for node in children {
            if node is SKSpriteNode {
                node.removeFromParent()
            }
        }
        FjordScoreManagerVC.shared.saveScore3(score)
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)
    }
}

class FjordsGameVC4: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        
        let scene = GameScene4(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}
