//
//  GameScene.swift
//  spaceinvaders
//
//  Created by Administrador on 25/10/23.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none     : UInt32 = 0
    static let all      : UInt32 = UInt32.max
    static let player   : UInt32 = 0b1
    static let ufo      : UInt32 = 0b10
    static let asteroid : UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var destroyedUfos = 0
    var player: SKSpriteNode!
    var label: SKLabelNode!
    var gameOver: SKLabelNode!
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: 0.0...1.0) * (max - min) + min
    }
    
    func randomSign() -> Int {
        let signs = [-1, 1]
        return signs.randomElement()!
    }
    
    func addUfo() {
        let ufo = SKSpriteNode(imageNamed: "ovni")
        let x = random(min: ufo.size.width / 2 - size.width / 2, max: size.width / 2 - ufo.size.width / 2)
        ufo.position = CGPoint(x: x, y: size.height + ufo.size.height / 2)
        ufo.zPosition = 0
        
        ufo.physicsBody = SKPhysicsBody(rectangleOf: ufo.size)
        ufo.physicsBody?.isDynamic = true
        ufo.physicsBody?.categoryBitMask = PhysicsCategory.ufo
        ufo.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ufo.physicsBody?.collisionBitMask = PhysicsCategory.none
        ufo.physicsBody?.usesPreciseCollisionDetection = true
        addChild(ufo)
        
        let duration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let move = SKAction.move(to: CGPoint(x: x, y: -size.height / 2), duration: TimeInterval(duration))
        let moveDone = SKAction.removeFromParent()
        ufo.run(SKAction.sequence([move, moveDone]))
    }
    
    func addAsteroid() {
        let sign = randomSign()
        let asteroid = SKSpriteNode(imageNamed: "asteroide")
        let y = random(min: asteroid.size.height / 2 - size.height / 2, max: size.height / 2 - asteroid.size.height / 2)
        asteroid.position = CGPoint(x: size.width + asteroid.size.width / 2 * CGFloat(sign), y: y )
        asteroid.zPosition = 0
        
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width/2)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.player
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.none
        asteroid.physicsBody?.usesPreciseCollisionDetection = true
        addChild(asteroid)
        
        let duration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let move = SKAction.move(to: CGPoint(x: (-size.width/2)*CGFloat(sign), y: y), duration: TimeInterval(duration))
        let moveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([move, moveDone]))
    }
    
    func startGame(){
        destroyedUfos = 0
        label.text = "Destroyed UFOs: " + String(destroyedUfos)
        gameOver.isHidden = true
        player.isHidden = false
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addUfo), SKAction.wait(forDuration: 1.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addAsteroid), SKAction.wait(forDuration: 2.0)])))
    }
    
    func endGame(){
        gameOver.isHidden = false
        player.isHidden = true
        removeAllActions()
        
    }
    
    func spaceshipCollidedWithUfo(player: SKSpriteNode, ufo: SKSpriteNode){
        destroyedUfos += 1
        label.text = "Destroyed UFOs: " + String(destroyedUfos)
        ufo.removeFromParent()
    }
    
    func spaceshipCollidedWithAsteroid(player: SKSpriteNode, asteroid: SKSpriteNode) {
        asteroid.removeFromParent()
        endGame()
    }
    
    override func didMove(to view: SKView) {
        player = (self.childNode(withName: "//spaceship") as! SKSpriteNode)
        player.zPosition = 0
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ufo
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        label = (self.childNode(withName: "//label") as! SKLabelNode)
        gameOver = (self.childNode(withName: "//gameover") as! SKLabelNode)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        startGame()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.ufo {
            spaceshipCollidedWithUfo(player: contact.bodyA.node as! SKSpriteNode, ufo: contact.bodyB.node as! SKSpriteNode)
        }
        if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.asteroid {
            spaceshipCollidedWithAsteroid(player: contact.bodyA.node as! SKSpriteNode, asteroid: contact.bodyB.node as! SKSpriteNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if !gameOver.isHidden && gameOver.contains(touch.location(in: self)){
            startGame()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if self.player != nil {
                player!.position = t.location(in: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
