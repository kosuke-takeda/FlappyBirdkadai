//
//  ViewController.swift
//  FlappyBird
//
//  Created by kohsuke.takeda on 2016/07/27.
//  Copyright © 2016年 kosuke.takeda. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SKViewに型を変換する
        let skView = self.view as! SKView
        
        // FPSを表示する
        skView.showsFPS = true
        
        // ノードの数を表示する
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size) // GameSceneクラスに変換する
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ステータスバーを消す　ーーーーー　ここから　ーーーーー
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //ーーーーー　ここまで　ーーーーー


}

