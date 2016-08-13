//
//  GameScene.swift
//  FlappyBird
//
//  Created by kohsuke.takeda on 2016/07/27.
//  Copyright © 2016年 kosuke.takeda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var itemNode:SKNode! //item
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4 //item
    
    // スコア用
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var itemScore = 0
    var itemScoreLabelNode:SKLabelNode! //item
 
    // SKView上にシーンが表示された時に呼び出されるメソッド
    override func didMoveToView(view: SKView){
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        // 背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // item
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel() //テキストに無かった所
        setupItem() //item
    }
    
    func setupItem() {
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let groundTexture = SKTexture(imageNamed: "ground")
        
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width * 2)
        let moveItem = SKAction.moveByX(-movingDistance, y: 0, duration:2.0)
        let removeItem = SKAction.removeFromParent()
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        // アイテムを生成
        let createItemAnimation = SKAction.runBlock({
            let item = SKSpriteNode(texture: itemTexture)
            item.zPosition = 10.0
            
            let random_y_range = self.frame.size.height
            let random_y = arc4random_uniform(UInt32(random_y_range))
            let item_y = CGFloat(random_y)
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width * 2, y: item_y / 2 + groundTexture.size().height)
            self.itemNode.addChild(item)
            
            item.physicsBody = SKPhysicsBody(rectangleOfSize: itemTexture.size())
            item.physicsBody?.categoryBitMask = self.itemCategory
            item.physicsBody?.collisionBitMask = 0
            item.physicsBody?.dynamic = false
            self.bird.physicsBody?.allowsRotation = false
            
            item.runAction(itemAnimation)
            
        })
        
        let waitAnimation = SKAction.waitForDuration(2)
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        runAction(repeatForeverAnimation)
        
    }

    
    func setupGround() {
        
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像１枚分スクロールさせるアクション
        let moveGround = SKAction.moveByX(-groundTexture.size().width ,y: 0, duration: 5.0)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        
        // 左にスクロール→もとの位置→左にスクロールと無限に切り替えるアクション
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        //for i:CGFloat in 0  ..< needNumber  {
        
        // 書き換え
        CGFloat(0).stride(to: needNumber, by: 1.0).forEach{
            i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
        // スプライトを表示する位置を指定する
        sprite.position = CGPoint(
            x: i * sprite.size.width,
            y: groundTexture.size().height / 2)
        
        //　スプライトにアクションを設定する
        sprite.runAction(repeatScrollGround)
        
        // スプライトに物理演算を設定する
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size()) //<追加
            
        // 衝突のカテゴリー設定
        sprite.physicsBody?.categoryBitMask = groundCategory
        
        // 衝突の時に動かないように設定する
        sprite.physicsBody?.dynamic = false // <追加
            
        // シーンにスプライトを追加する
        scrollNode.addChild(sprite)
            
        }
    }
    
    func setupCloud() {
        //　雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // 必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        // スクロールするアクションを作成
        // 左方向に画像１枚分スクロールさせるアクション
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width ,y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveByX(cloudTexture.size().width ,y: 0, duration: 0.0)
        
        // 左にスクロール　ー＞元の位置　ー＞左にスクロール　と無限に切り替えるアクション
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        CGFloat(0).stride(to: needCloudNumber, by: 1.0).forEach{
            i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 //一番後ろになるようにする
            
            // スプライトを表示する位置を指定する
            sprite.position = CGPoint(
                x: i * sprite.size.width,
                y: size.height - cloudTexture.size().height / 2)
                
            
            //　スプライトにアクションを設定する
            sprite.runAction(repeatScrollCloud)
            
            // シーンにスプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration:4.0)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // ２つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.runBlock({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0.0)
            wall.zPosition = -50.0 // 雲より手前　地面より奥
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            
            // 壁のY軸を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY軸座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size()) //<追加
            under.physicsBody?.categoryBitMask = self.wallCategory // <追加
            
            // 衝突の時に動かないように設定する
            under.physicsBody?.dynamic = false // <追加
            
            
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size()) //<追加
            upper.physicsBody?.categoryBitMask = self.wallCategory // <追加

            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.dynamic = false // <追加
            
            wall.addChild(upper)
            
            // ---ここから---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(
                x: upper.size.width + self.bird.size.width / 2,
                y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            // ---ここまで---
            
            
            
            wall.runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
            
        })
        
        // 次の壁を作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        // 壁を作成＞待ち時間＞壁を作成を無限繰り返すアクション
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
    
    
    
    
    func setupBird() {
        // 鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .Linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .Linear
        
        //　２種類の画像を交互に変更するアニメーションを作成
        let textureAnimation = SKAction.animateWithTextures([birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(textureAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0) // < 追加
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory //item追加
        
        
        // アニメーションを設定
        bird.runAction(flap)
        
        // スプライトを追加
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0 {
            
        // 鳥の速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero
        
        // 鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            
        }else if bird.speed == 0 {
            restart()
        }
    }
    

    // SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBeginContact(contact: SKPhysicsContact) {
        //gameoverの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory||(contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.setInteger(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory||(contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            
            itemScore += 1
            itemScoreLabelNode.text = "ItemScore:\(itemScore)"
            
            let music = SKAction.playSoundFileNamed("item.mp3", waitForCompletion: true)
            self.runAction(music)

            if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory {
                contact.bodyA.node?.removeFromParent()
            }
            
            if (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                contact.bodyB.node?.removeFromParent()
            }
            
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.runAction(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.blackColor()
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        itemScoreLabelNode.text = "ItemScore:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
    }

    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        
        itemScore = 0
        itemScoreLabelNode.text = String("ItemScore:\(itemScore)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2,
                                y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory | itemCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        itemNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
    }
}




