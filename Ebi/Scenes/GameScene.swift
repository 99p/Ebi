//
//  GameScene.swift
//  Ebi
//
//  Created by macboy on 2022/07/18.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct Constants{
        static let PlayerImages = [ "shrimp01", "shrimp02", "shrimp03", "shrimp04" ]
    }
    
    struct ColliderType {
        static let Player: UInt32 = (1 << 0)
        static let World:  UInt32 = (1 << 1)
        static let Coral:  UInt32 = (1 << 2)
        static let Score:  UInt32 = (1 << 3)
        static let None:   UInt32 = (1 << 4)
    }
    
    var baseNode: SKNode!
    var coralNode: SKNode!
    var yscale: CGFloat = 0.0
    
    var player: SKSpriteNode!
    
    var scoreLabelNode: SKLabelNode!
    var score: UInt32!
    
    override func sceneDidLoad() {
        self.scaleMode = .resizeFill
//        self.anchorPoint = CGPoint(x: 0.5,
//                                   y: 0.5)
    }
    
    override func didMove(to view: SKView) {
        
        score = 0
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        
        // 全ノードの親となるノードを生成
        baseNode = SKNode()
        baseNode.speed = 1.0
        self.addChild(baseNode)
        
        // 障害物を追加するノードを生成
        coralNode = SKNode()
        baseNode.addChild(coralNode)
        
        // 背景画像を構築
        self.setupBackgroundSea()
        self.setupBackgroundRock()
        self.setupCeilingAndLand()
        
        self.setupPlayer()
        self.setupCoral()
        self.setupScoreLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if 0.0 < baseNode.speed {
            for touch: AnyObject in touches{
                let location = touch.location(in: self)
                // プレイヤーに加えられている力をゼロにする
                player.physicsBody?.velocity = CGVector.zero
                // ぷれいやーにy軸方向へ力を加える
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 23.0))
            }
        } else if baseNode.speed == 0.0 && player.speed == 0.0 {
            // remove all coral
            coralNode.removeAllChildren()
            
            // reset Score
            score = 0
            scoreLabelNode.text = String(score)
            
            // reset player pos
            player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
            player.physicsBody?.velocity = CGVector.zero
            player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
            player.zRotation = 0.0
            
            // start anim
            player.speed = 1.0
            baseNode.speed = 1.0
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // if already Gameover
        if baseNode.speed <= 0.0 {
            return
        }
        
        let rawScoreType = ColliderType.Score
        let rawNoneType = ColliderType.None
        if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType || (contact.bodyB.categoryBitMask & rawScoreType) == rawScoreType {
            // add Score
            score = score + 1
            scoreLabelNode.text = String(score)
            
            // Animate ScoreLabel
            let scaleUpAnim = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDownAnim = SKAction.scale(to: 1.0, duration: 0.1)
            scoreLabelNode.run(SKAction.sequence([scaleUpAnim, scaleDownAnim]))
            
            // change Score bitmask
            if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType {
                contact.bodyA.categoryBitMask = ColliderType.None
                contact.bodyA.contactTestBitMask = ColliderType.None
            } else {
                contact.bodyB.categoryBitMask = ColliderType.None
                contact.bodyB.contactTestBitMask = ColliderType.None
            }
        } else if (contact.bodyA.categoryBitMask & rawNoneType) == rawNoneType || (contact.bodyB.categoryBitMask & rawNoneType) == rawNoneType {
            // pass
        } else {
            // stop ALL baseNode anim
            baseNode.speed = 0.0
            // change player bitmask
            player.physicsBody?.collisionBitMask = ColliderType.World
            // enforce player rotate anim
            let rolling = SKAction.rotate(byAngle: CGFloat(M_PI) * player.position.y * 0.01, duration: 1.0)
            player.run(rolling, completion: {
                self.player.speed = 0.0
            })
        }
    }
    
    func setupBackgroundSea(){
        // 背景画像を読み込む
        let texture = SKTexture(imageNamed: "background")
        texture.filteringMode = .nearest
        
        // 必要な画像枚数を算出
        let needNumber = 2.0 + ceil(self.frame.size.width / texture.size().width)
        yscale = self.frame.size.height / texture.size().height
        
        // アニメーションを作成
        let moveAnim = SKAction.moveBy(x: -self.frame.size.width,
                                       y: 0.0,
                                       duration: TimeInterval(self.frame.size.width / 18))
        let resetAnim = SKAction.moveBy(x: self.frame.size.width,
                                        y: 0.0,
                                        duration: 0.0)
        let repeatAction = SKAction.sequence([moveAnim, resetAnim])
        let repeatForeverAnim = SKAction.repeatForever(repeatAction)
        
        // 画像の配置とアニメーションを設定
        for num in 0 ..< Int(needNumber) {
            let i: CGFloat = CGFloat(num)
            let sprite = SKSpriteNode(texture: texture)
            sprite.zPosition = -100.0
            sprite.xScale = self.frame.size.width / sprite.size.width
            sprite.yScale = yscale
            sprite.position = CGPoint(x: i*sprite.size.width, y: self.frame.size.height/2.0)
            sprite.run(repeatForeverAnim)
            baseNode.addChild(sprite)
        }
    }
    
    func setupBackgroundRock(){
        // 岩山画像をよっみmコム
        let under = SKTexture(imageNamed: "rock_under")
        under.filteringMode = .nearest
        
        // 必要な画像枚数を算出
        let needNumber = 2.0 + ceil(self.frame.size.width / under.size().width)
        
        // アニメーションを作成
        let moveUnderAnim = SKAction.moveBy(x: -self.frame.size.width,
                                            y: 0.0,
                                            duration: TimeInterval(self.frame.size.width / 30.0))
        let resetUnderAnim = SKAction.moveBy(x: self.frame.size.width,
                                             y: 0.0,
                                             duration: 0.0)
        let repeatForeverUnderAnim = SKAction.repeatForever(SKAction.sequence([ moveUnderAnim, resetUnderAnim]))
        
        // 画像の配置とアニメーションを設定
        for num in 0 ..< Int(needNumber){
            let i: CGFloat = CGFloat(num)
            let sprite = SKSpriteNode(texture: under)
            sprite.zPosition = -50.0
            let scale  = self.frame.size.width  / sprite.size.width
            sprite.setScale(scale)
            sprite.yScale = yscale
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            sprite.run(repeatForeverUnderAnim)
            baseNode.addChild(sprite)
        }
        
        let above = SKTexture(imageNamed: "rock_above")
        above.filteringMode = .nearest
        
        let moveAboveAnim = SKAction.moveBy(x: -self.frame.size.width,
                                            y: 0.0,
                                            duration: TimeInterval(self.frame.size.width / 30.0))
        let resetAboveAnim = SKAction.moveBy(x: self.frame.size.width,
                                             y: 0.0,
                                             duration: 0.0)
        let repeatForeverAboveAnim = SKAction.repeatForever(SKAction.sequence([ moveAboveAnim, resetAboveAnim]))

        // 画像の配置とアニメーションを設定
        for num in 0 ..< Int(needNumber){
            let i: CGFloat = CGFloat(num)
            let sprite = SKSpriteNode(texture: above)
            sprite.zPosition = -50.0
            sprite.setScale(self.frame.size.width/sprite.size.width)
            sprite.yScale = yscale
            sprite.position = CGPoint(x: i * sprite.size.width,
                                      y: self.frame.size.height - (sprite.size.height / 2.0))
            sprite.run(repeatForeverAboveAnim)
            baseNode.addChild(sprite)
        }
        
    }
    
    func setupCeilingAndLand(){
        // load images
        let land = SKTexture(imageNamed: "land")
        land.filteringMode = .nearest
        
        // neednumber
        var needNumber = 2.0 + ceil(self.frame.size.width / land.size().width)
        
        // create Animation
        let moveLandAnim = SKAction.moveBy(x: -land.size().width,
                                           y: 0.0,
                                           duration: TimeInterval(land.size().width / 80.0))
        let resetLandAnim = SKAction.moveBy(x: land.size().width,
                                            y: 0.0,
                                            duration: 0.0)
        let sequenceLandAnim = SKAction.sequence([ moveLandAnim, resetLandAnim ])
        let repeatForeverLandAnim = SKAction.repeatForever(sequenceLandAnim)
        
        // set images and Animations
        for num in 0 ..< Int(needNumber){
            let i: CGFloat = CGFloat(num)
            let sprite = SKSpriteNode(texture: land)
            sprite.position = CGPoint(x: i * sprite.size.width,
                                      y: sprite.size.height / 2.0)
            sprite.physicsBody = SKPhysicsBody(texture: land,
                                               size:land.size())
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            sprite.run(repeatForeverLandAnim)
            baseNode.addChild(sprite)
        }
        // load images
        let ceiling = SKTexture(imageNamed: "ceiling")
        ceiling.filteringMode = .nearest
        
        // neednumber
        needNumber = 2.0 + ceil(self.frame.size.width / ceiling.size().width)
        
        // create Animation
        let moveCeilingAnim = SKAction.moveBy(x: -ceiling.size().width,
                                           y: 0.0,
                                           duration: TimeInterval(ceiling.size().width / 80.0))
        let resetCeilingAnim = SKAction.moveBy(x: ceiling.size().width,
                                            y: 0.0,
                                            duration: 0.0)
        let sequenceCeilingAnim = SKAction.sequence([ moveCeilingAnim, resetCeilingAnim ])
        let repeatForeverCeilingAnim = SKAction.repeatForever(sequenceCeilingAnim)
        
        // set images and Animations
        for num in 0 ..< Int(needNumber){
            let i: CGFloat = CGFloat(num)
            let sprite = SKSpriteNode(texture: ceiling)
            sprite.position = CGPoint(x: i * sprite.size.width,
                                      y: self.frame.size.height / 1.05)
            sprite.physicsBody = SKPhysicsBody(texture: ceiling,
                                               size:ceiling.size())
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            sprite.run(repeatForeverCeilingAnim)
            baseNode.addChild(sprite)
        }

        
    }
    
    func setupPlayer(){
        // Playerのパラパラアニメーション作成に必要なSKTextureクラスの配列を定義
        var playerTexture = [SKTexture]()
        
        // パラパラアニメーションに必要な画像を読み込む
        for imageName in Constants.PlayerImages{
            let texture = SKTexture(imageNamed: imageName)
            texture.filteringMode = .linear
            playerTexture.append(texture)
        }
        
        // パラパラ漫画のアニメーションを作成
        let playerAnimation = SKAction.animate(with: playerTexture, timePerFrame: 0.2)
        let loopAnimation = SKAction.repeatForever(playerAnimation)
        
        // キャラクターを生成し、アニメーションを設定
        player = SKSpriteNode(texture: playerTexture[0])
        player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
        player.run(loopAnimation)
        
        // 物理シミュレーションを設定
        player.physicsBody = SKPhysicsBody(texture: playerTexture[0], size: playerTexture[0].size())
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        
        //自分自身にPlayerカテゴリを設定
        player.physicsBody?.categoryBitMask = ColliderType.Player
        //衝突判定相手にWorldとCoralを設定
        player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
        player.physicsBody?.contactTestBitMask = ColliderType.World | ColliderType.Coral
        
        self.addChild(player)
    }
    
    func setupCoral(){
        // load Coral image
        let coralUnder = SKTexture(imageNamed: "coral_under")
        coralUnder.filteringMode = .linear
        let coralAbove = SKTexture(imageNamed: "coral_above")
        coralAbove.filteringMode = .linear
        
        // calc move distance
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * coralUnder.size().width)
        
        // make anim
        let moveAnim = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(distanceToMove / 100.0))
        let removeAnim = SKAction.removeFromParent()
        let coralAnim = SKAction.sequence([moveAnim, removeAnim])
        
        // サンゴを生成するメソッドを呼び出すアニメーションを作成
        let newCoralAnim = SKAction.run({
            // make Coral's Node
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.size.width + coralUnder.size().width * 2, y: 0.0)
            coral.zPosition = -40.0
            
            // calc bottom Coral's y coordinate
            let height = UInt32(self.frame.size.height / 12)
            let y = CGFloat(arc4random_uniform(height * 2) + height)
            
            // gen bottom Coral
            let under = SKSpriteNode(texture: coralUnder)
            under.position = CGPoint(x: 0.0, y: y)
            
            // set Physics to Coral
            under.physicsBody = SKPhysicsBody(texture: coralUnder, size: under.size)
            under.physicsBody?.isDynamic = false
            under.physicsBody?.categoryBitMask = ColliderType.Coral
            under.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(under)
            
            // gen top Coral
            let above = SKSpriteNode(texture: coralAbove)
            above.position = CGPoint(x: 0.0, y: y + (under.size.height / 2.0) + 160.0 + (above.size.height / 2.0))
            
            // set physics to Coral
            above.physicsBody = SKPhysicsBody(texture: coralAbove, size: above.size)
            above.physicsBody?.isDynamic = false
            above.physicsBody?.categoryBitMask = ColliderType.Coral
            above.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(above)
            
            // gen countup Score Node
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: (above.size.width / 2.0) + 5.0, y: self.frame.height / 2.0)
            
            // set physics to ScoreNode
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10.0, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
            scoreNode.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(scoreNode)
            
            coral.run(coralAnim)
            self.coralNode.addChild(coral)
            
        })
        let delayAnim = SKAction.wait(forDuration: 2.5)
        let repeatForeverAnim = SKAction.repeatForever(SKAction.sequence([newCoralAnim, delayAnim]))
        
        self.run(repeatForeverAnim)
    }
    
    func setupScoreLabel(){
        // gen Label as "Arial Bold"
        scoreLabelNode = SKLabelNode(fontNamed: "Arial Bold")
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: self.frame.width / 2.0, y: self.frame.height * 0.9)
        scoreLabelNode.zPosition = 100.0
        scoreLabelNode.text = String(score)
        
        self.addChild(scoreLabelNode)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
