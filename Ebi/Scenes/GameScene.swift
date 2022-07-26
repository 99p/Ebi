//
//  GameScene.swift
//  Ebi
//
//  Created by macboy on 2022/07/18.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    var baseNode: SKNode!
    var coralNode: SKNode!
    var yscale: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
//        self.backgroundColor = .purple
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
    }
    
//    func simpp(){
//        let tex = SKTexture(imageNamed: "background")
//        let sprite = SKSpriteNode(texture: tex)
//        sprite.setScale(self.frame.size.width/tex.size().width)
//        sprite.position = CGPoint(x: sprite.size.width/2, y: self.frame.size.height/2.0)
//        baseNode.addChild(sprite)
//    }
    
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
                                       duration: TimeInterval(self.frame.size.width * 18))
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
                                            duration: TimeInterval(self.frame.size.width * 5.0))
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
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 4.0)
            sprite.run(repeatForeverUnderAnim)
            baseNode.addChild(sprite)
        }
        
        let above = SKTexture(imageNamed: "rock_above")
        above.filteringMode = .nearest
        
        let moveAboveAnim = SKAction.moveBy(x: -self.frame.size.width,
                                            y: 0.0,
                                            duration: TimeInterval(self.frame.size.width * 5.0))
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
                                      y: self.frame.size.height - (sprite.size.height / 100.0))
            sprite.run(repeatForeverAboveAnim)
            baseNode.addChild(sprite)
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
