//
//  GameScene.swift
//  Dope Shit
//
//  Created by Kevin Largo on 2/2/15.
//  Copyright (c) 2015 xkevlarproductions. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
  //Constants
  let titleCategory: UInt32 = 0x1 << 1
  let playButtonCategory: UInt32 = 0x1 << 2
  let titleShelfCategory: UInt32 = 0x1 << 3
  let playButtonShelfCategory: UInt32 = 0x1 << 4
  
  let title = SKSpriteNode(imageNamed: "Title")
  let titleShelf = SKSpriteNode()
  let playButton = SKSpriteNode(imageNamed: "Play Button")
  let playButtonShelf = SKSpriteNode()
  
  var noPlayAddedYet = true
  
  let ground = SKSpriteNode(imageNamed: "Ground")
  let clouds1 = SKSpriteNode(imageNamed: "Clouds")
  let clouds2 = SKSpriteNode(imageNamed: "Clouds")
  let clouds3 = SKSpriteNode(imageNamed: "Clouds")
  let clouds4 = SKSpriteNode(imageNamed: "Clouds")
  
  var cloudsSpeed = 1
  var maxCloudsX = CGFloat(0)
  
  override func didMoveToView(view: SKView) {
    playBackgroundMusic("8 Bit Intro.mp3")
    backgroundColor = UIColor(hex: 0x66DDFF)  //background sky color
    createClouds()
    
    ground.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) / 3 - ground.size.height / 2)
    addChild(ground)
    
    dropTitle()
    dropPlayButton()
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches{
      let location = touch.locationInNode(self) //location touched is title
      
      if(self.nodeAtPoint(location) == self.title) {
        
        var scene = PlayScene(size: self.size)
        let skView = self.view! as SKView
        scene.size = skView.bounds.size
        skView.presentScene(scene)
      }
      
      if(self.nodeAtPoint(location) == playButton) {
        var scene = PlayScene(size: self.size)
        let skView = self.view! as SKView
        scene.size = skView.bounds.size
        skView.presentScene(scene)
      }
    }
  }
  
  override func update(currentTime: NSTimeInterval) {
    if clouds1.position.x < maxCloudsX{
      clouds1.position.x = clouds4.position.x + clouds4.size.width
    }
    
    if clouds2.position.x < maxCloudsX{
      clouds2.position.x = clouds1.position.x + clouds1.size.width
    }
    
    if clouds3.position.x < maxCloudsX{
      clouds3.position.x = clouds2.position.x + clouds2.size.width
    }
    
    if clouds4.position.x < maxCloudsX{
      clouds4.position.x = clouds3.position.x + clouds3.size.width
    }
    
    //move clouds
    clouds1.position.x -= CGFloat(self.cloudsSpeed)
    clouds2.position.x -= CGFloat(self.cloudsSpeed)
    clouds3.position.x -= CGFloat(self.cloudsSpeed)
    clouds4.position.x -= CGFloat(self.cloudsSpeed)
  }
  
  func createClouds() {
    //Background Clouds
    clouds1.anchorPoint = CGPointMake(0, 0.5)
    clouds2.anchorPoint = CGPointMake(0, 0.5)
    clouds3.anchorPoint = CGPointMake(0, 0.5)
    clouds4.anchorPoint = CGPointMake(0, 0.5)
    
    clouds1.position = CGPointMake(0, CGRectGetMidY(frame) * 1.35)
    clouds2.position = CGPointMake(clouds1.position.x + clouds1.size.width, CGRectGetMidY(frame) * 1.35)
    clouds3.position = CGPointMake(clouds2.position.x + clouds2.size.width, CGRectGetMidY(frame) * 1.35)
    clouds4.position = CGPointMake(clouds3.position.x + clouds3.size.width, CGRectGetMidY(frame) * 1.35)
    
    addChild(clouds1)
    addChild(clouds2)
    addChild(clouds3)
    addChild(clouds4)
    
    maxCloudsX = clouds1.size.width
    maxCloudsX *= -1
  }
  
  func dropTitle() {
    //Title Label
    title.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)*1.5)
    title.zPosition = 2
    title.physicsBody = SKPhysicsBody(rectangleOfSize: title.size)
    title.physicsBody!.dynamic = true
    title.physicsBody?.categoryBitMask = titleCategory
    title.physicsBody?.contactTestBitMask = titleShelfCategory
    title.physicsBody?.collisionBitMask = titleShelfCategory
    addChild(title)
    
    //Title Shelf
    titleShelf.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0,CGRectGetMidY(frame) + title.size.height / 4),
      toPoint: CGPointMake(frame.size.width,CGRectGetMidY(frame) + title.size.height / 4))
    titleShelf.physicsBody?.dynamic = false
    titleShelf.physicsBody?.categoryBitMask = titleShelfCategory
    titleShelf.physicsBody?.collisionBitMask = titleCategory
    addChild(titleShelf)
  }
  
  func dropPlayButton() {
    if noPlayAddedYet{
      //PlayButton
      playButton.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame)*1.5)
      playButton.zPosition = 1
      playButton.physicsBody = SKPhysicsBody(rectangleOfSize: playButton.size)
      playButton.physicsBody?.velocity.dy = -2
      playButton.physicsBody?.dynamic = true
      playButton.physicsBody?.categoryBitMask = playButtonCategory
      playButton.physicsBody?.collisionBitMask = playButtonShelfCategory
      addChild(playButton)
      
      //PlayButton Shelf
      playButtonShelf.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0,CGRectGetMidY(frame) / 2),
        toPoint: CGPointMake(frame.size.width,CGRectGetMidY(frame) / 2))
      playButtonShelf.physicsBody?.dynamic = false
      playButtonShelf.physicsBody?.categoryBitMask = playButtonShelfCategory
      playButtonShelf.physicsBody?.collisionBitMask = playButtonCategory
      addChild(playButtonShelf)
      
      //Used so that function doesn't get called twice when Title bounces
      noPlayAddedYet = false
    }
  }
}
