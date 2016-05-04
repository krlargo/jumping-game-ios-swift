//
//  PlayScene.swift
//  Skip Game
//
//  Created by Kevin Largo on 1/30/15.
//  Copyright (c) 2015 xkevlarproductions. All rights reserved.
//

import SpriteKit
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!
func playBackgroundMusic(filename: String) {
  let url = NSBundle.mainBundle().URLForResource(
    filename, withExtension: nil)
  if (url == nil) {
    println("Could not find file: \(filename)")
    return
  }
  
  var error: NSError? = nil
  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
  if backgroundMusicPlayer == nil {
    println("Could not create audio player: \(error!)")
    return
  }
  
  backgroundMusicPlayer.numberOfLoops = -1
  backgroundMusicPlayer.prepareToPlay()
  backgroundMusicPlayer.play()
}

//bitMask Categories
let playerCategory: UInt32 = 0x1 << 1
let groundCategory: UInt32 = 0x1 << 2
let killCategory: UInt32 = 0x1 << 3
let gameOverCategory: UInt32 = 0x1 << 4
let retryCategory: UInt32 = 0x1 << 5
let gameOverShelfCategory: UInt32 = 0x1 << 6
let retryShelfCategory: UInt32 = 0x1 << 7
let obstacleCategory: UInt32 = 0x1 << 8

class PlayScene: SKScene, SKPhysicsContactDelegate{
  var startPoint = CGPoint()
  
  //Music
  var backgroundMusic = "0 to 100.mp3"
  var playMusic = true
  var musicButton = SKSpriteNode(imageNamed: "Music Button")
  
  //Ground Declaration
  let ground = SKSpriteNode(imageNamed: "Ground")
  let copyGround = SKSpriteNode(imageNamed: "Ground")
  var maxGroundX = CGFloat(0)
  var maxHoleX = CGFloat(0)
  var killWall = SKSpriteNode()
  
  //Holes Declaration
  let hole = SKSpriteNode(imageNamed: "Ground Hole")
  
  //Crate Obstacle
  let crate = SKSpriteNode(imageNamed: "Wooden Crate")
  
  //Clouds Declaration
  let clouds = SKSpriteNode(imageNamed: "Clouds")
  let copyClouds = SKSpriteNode(imageNamed: "Clouds")
  var maxCloudsX = CGFloat(0)
  
  //Player Traits
  var player = AnimatedNode()
  var jumpSound = SKAction.playSoundFileNamed("JumpSound.wav", waitForCompletion: false)
  
  //Game Over and Retry shelves
  var gameOver = SKSpriteNode()
  var gameOverShelf = SKSpriteNode()
  var retryShelf = SKSpriteNode()
  let retry = SKSpriteNode(imageNamed: "Retry") //must be declared globally since it is a button
  var noRetryAddedYet = true
  
  override func didMoveToView(view: SKView){
    self.backgroundColor = UIColor(hex: 0x66DDFF)  //background sky color
    setMusic()
    createWorld()
    
    //Insert Player Character
    player = AnimatedNode(atlasName: "selfie.atlas", filePrefix: "Selfie", frameCount: 8)
    startPoint = CGPoint(x: self.frame.width * 0.2, y: self.frame.size.height * 3.0)
    player.sprite.position = startPoint
    addChild(self.player.sprite)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
    for touch: AnyObject in touches {
      
      let location = touch.locationInNode(self)
      
      //if screen touched while dy-velocity is 0, then allow jump
      if player.sprite.physicsBody!.velocity.dy == 0 && self.nodeAtPoint(location) != musicButton{
        runAction(jumpSound)
        player.sprite.physicsBody!.velocity = CGVectorMake(0, 0)
        player.sprite.physicsBody!.applyImpulse(CGVectorMake(0, 120))
      }
      
      if(self.nodeAtPoint(location) == retry) {
        /*
        //used for restarting straight to PlayScene
        var scene = PlayScene(size: self.size)
        let skView = self.view! as SKView
        scene.size = skView.bounds.size
        skView.presentScene(scene)
        */
        
        //used for returning to GameScene
        var scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        let skView = self.view! as SKView
        scene?.size = skView.bounds.size
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        
        skView.presentScene(scene)
      }
      
      if(self.nodeAtPoint(location) == musicButton) {
        pressMusicButton()
      }
    }
  }
  
  override func update(currentTime: NSTimeInterval) {
    if !player.died {//player.sprite.position.y > CGRectGetMinY(frame) && player.sprite.position.x > 0 {
      scrollBackground(6)
      scrollClouds(3)
    }
      
    else {
      scrollClouds(0.5) //cloud scroll is much slower
    }
    
    //if velocity is nonZero, animate jump
    if player.sprite.physicsBody!.velocity.dy != 0 {
      player.sprite.runAction(player.runningAction)
    }
    
    //when player runs into obstacle and is pushed back, he will run back to startPoint
    if player.sprite.position.x < startPoint.x {
      //  player.sprite.physicsBody!.velocity = CGVectorMake(1, 0)
    }
    
    crate.position.x = copyGround.position.x
  }
  
  func createWorld() {
    //Initial Positions
    ground.position = CGPointMake(leftEdge(ground), CGRectGetMidY(frame) / 3 - ground.size.height / 2)
    hole.position = CGPointMake(rightEdge(ground) + leftEdge(hole), CGRectGetMidY(frame) / 3 - ground.size.height / 2)
    copyGround.position = CGPointMake(rightEdge(hole) + leftEdge(copyGround), CGRectGetMidY(frame) / 3 - ground.size.height / 2)
    
    ground.physicsBody = SKPhysicsBody(rectangleOfSize:ground.size)
    ground.physicsBody!.dynamic = false
    ground.physicsBody!.allowsRotation = false
    ground.physicsBody!.restitution = 0
    copyGround.physicsBody = SKPhysicsBody(rectangleOfSize:copyGround.size)
    copyGround.physicsBody!.dynamic = false
    copyGround.physicsBody!.allowsRotation = false
    copyGround.physicsBody!.restitution = 0
    
    //Ground Collision Traits
    ground.physicsBody?.categoryBitMask = groundCategory
    ground.physicsBody?.collisionBitMask = playerCategory///
    copyGround.physicsBody?.categoryBitMask = groundCategory
    copyGround.physicsBody?.collisionBitMask = playerCategory
    //copyGround.physicsBody?.contactTestBitMask = playerCategory //causes to player to die on contact with
    
    addChild(ground)
    addChild(hole)
    addChild(copyGround)
    
    maxGroundX = ground.size.width / 2 + frame.size.width
    maxGroundX *= -1
    maxHoleX = hole.size.width
    maxHoleX *= -1
    
    self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
    self.physicsWorld.contactDelegate = self
    
    //Crate Obstacles
    crate.physicsBody = SKPhysicsBody(rectangleOfSize:crate.size)
    crate.physicsBody!.dynamic = false
    crate.physicsBody!.restitution = 0
    crate.position.y = ground.position.y + (ground.size.height + crate.size.height) / 2
    crate.physicsBody?.categoryBitMask = obstacleCategory
    addChild(crate)
    
    //Background Clouds
    clouds.anchorPoint = CGPointMake(0, 0.5)
    copyClouds.anchorPoint = CGPointMake(0, 0.5)
    
    clouds.position = CGPointMake(0, CGRectGetMidY(frame) * 1.35)
    clouds.zPosition = -1;
    copyClouds.position = CGPointMake(clouds.size.width, CGRectGetMidY(frame) * 1.35)
    copyClouds.zPosition = -1;
    
    addChild(clouds)
    addChild(copyClouds)
    
    maxCloudsX = clouds.size.width * 2 - frame.size.width
    maxCloudsX *= -1
    
    //Kill Collision Traits
    self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0,0), toPoint: CGPointMake(frame.size.width,0))
    self.physicsBody?.categoryBitMask = killCategory
    self.physicsBody?.contactTestBitMask = playerCategory
    self.physicsBody?.collisionBitMask = 0
    
    killWall.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-60, CGRectGetMaxY(frame)), toPoint: CGPointMake(-60,0))
    killWall.physicsBody?.categoryBitMask = killCategory
    killWall.physicsBody?.contactTestBitMask = playerCategory
    killWall.physicsBody?.collisionBitMask = 0
    addChild(killWall)
    
    /*
    Collision Notes:
    categoryBitMask: is the category this body belongs to
    contactTestBitMask: detects interactions with these categories
    collisionBitMask: collides with (touches) these categories
    */
  }
  
  func didBeginContact(contact:SKPhysicsContact!) {
    var firstBody, secondBody: SKPhysicsBody
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    }
      
    else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    //kill player for going off screen
    if(firstBody.categoryBitMask & playerCategory) != 0 && //if they match
      (secondBody.categoryBitMask & killCategory) != 0 { //if they match
        playerLost()
    }
    
    if(firstBody.categoryBitMask & playerCategory) != 0 &&
      (secondBody.categoryBitMask & groundCategory) != 0 {
        player.sprite.physicsBody!.restitution = 0
    }
  }
  
  func dropGameOverLabel() {
    //GameOver Label
    gameOver = SKSpriteNode(imageNamed: "Game Over")
    gameOver.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)*1.5)
    gameOver.zPosition = 1
    gameOver.physicsBody = SKPhysicsBody(rectangleOfSize: gameOver.size)
    gameOver.physicsBody!.dynamic = true
    gameOver.physicsBody?.categoryBitMask = gameOverCategory
    gameOver.physicsBody?.contactTestBitMask = gameOverShelfCategory
    gameOver.physicsBody?.collisionBitMask = gameOverShelfCategory
    addChild(gameOver)
    
    //GameOver Shelf
    gameOverShelf.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0,CGRectGetMidY(frame) + gameOver.size.height / 4),
      toPoint: CGPointMake(frame.size.width,CGRectGetMidY(frame) + gameOver.size.height / 4))
    gameOverShelf.physicsBody?.dynamic = false
    gameOverShelf.physicsBody?.categoryBitMask = gameOverShelfCategory
    gameOverShelf.physicsBody?.collisionBitMask = gameOverCategory
    addChild(gameOverShelf)
  }
  
  func dropRetryButton() {
    if noRetryAddedYet{
      //Retry Button
      retry.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame)*1.5)
      retry.physicsBody = SKPhysicsBody(rectangleOfSize: retry.size)
      retry.physicsBody?.velocity.dy = -2
      retry.physicsBody?.dynamic = true
      retry.physicsBody?.categoryBitMask = retryCategory
      retry.physicsBody?.collisionBitMask = retryShelfCategory
      addChild(retry)
      
      //Retry Shelf
      retryShelf.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0,CGRectGetMidY(frame) / 2),
        toPoint: CGPointMake(frame.size.width,CGRectGetMidY(frame) / 2))
      retryShelf.physicsBody?.dynamic = false
      retryShelf.physicsBody?.categoryBitMask = retryShelfCategory
      retryShelf.physicsBody?.collisionBitMask = retryCategory
      addChild(retryShelf)
      
      //Used so that function doesn't get called twice when GameOver bounces
      noRetryAddedYet = false
    }
  }
  
  func leftEdge(sprite: SKSpriteNode) -> CGFloat {
    return sprite.size.width / 2
  }
  
  func rightEdge(sprite: SKSpriteNode) -> CGFloat {
    return sprite.position.x + sprite.size.width / 2
  }
  
  func playerLost() {
    backgroundMusicPlayer.stop()
    
    if playMusic {
      playBackgroundMusic("I Don't Give A Fuck.mp3")
    }
    
    player.died = true
    
    dropGameOverLabel()
    dropRetryButton()
  }
  
  func pressMusicButton()
  {
    var pressPause = SKAction.setTexture(SKTexture(imageNamed: "Mute Button"), resize: true)
    var pressPlay = SKAction.setTexture(SKTexture(imageNamed: "Music Button"), resize: true)
    
    if playMusic {
      //set to pause
      playMusic = false
      musicButton.runAction(pressPause)
      backgroundMusicPlayer.pause()
    }
      
    else { //is set to pause
      //set to play
      playMusic = true
      musicButton.runAction(pressPlay)
      backgroundMusicPlayer.play()
    }
  }
  
  func setMusic() {
    playBackgroundMusic(backgroundMusic)
    musicButton.physicsBody = SKPhysicsBody(rectangleOfSize: musicButton.size)
    musicButton.physicsBody!.dynamic = false
    musicButton.zPosition = 1
    musicButton.position = CGPointMake(frame.size.width - 35, 35)
    addChild(musicButton)
  }
  
  func scrollBackground(groundSpeed: Float) {
    if ground.position.x < maxGroundX {
      ground.position.x = rightEdge(hole) + leftEdge(ground)
    }
    
    if copyGround.position.x < maxGroundX {
      copyGround.position.x = rightEdge(hole) + leftEdge(copyGround)
    }
    
    if hole.position.x < maxHoleX {
      if ground.position.x < copyGround.position.x {
        hole.position.x = rightEdge(copyGround) + leftEdge(hole)
      }
      else {
        hole.position.x = rightEdge(ground) + leftEdge(hole)
      }
    }
    
    ground.position.x -= CGFloat(groundSpeed)
    copyGround.position.x -= CGFloat(groundSpeed)
    hole.position.x -= CGFloat(groundSpeed)
  }
  
  func scrollClouds(cloudsSpeed: Float) {
    if clouds.position.x < maxCloudsX {
      clouds.position.x = copyClouds.position.x + copyClouds.size.width
    }
    
    if copyClouds.position.x < maxCloudsX {
      copyClouds.position.x = clouds.position.x + clouds.size.width
    }
    
    clouds.position.x -= CGFloat(cloudsSpeed)
    copyClouds.position.x -= CGFloat(cloudsSpeed)
  }
}

struct AnimatedNode {
  var spriteAtlas: SKTextureAtlas!
  var spriteArray: Array<SKTexture>!
  var sprite: SKSpriteNode!
  
  var originalHeight = CGFloat()
  var runningAction = SKAction()
  var jumpAction = SKAction()
  
  var died = false
  
  init(){}
  
  init(atlasName: String, filePrefix: String, frameCount: Int)
  {
    spriteAtlas = SKTextureAtlas(named:atlasName)
    spriteArray = Array<SKTexture>()
    sprite = SKSpriteNode()
    
    //create running animation
    for i in 1...frameCount {
      spriteArray.append(spriteAtlas.textureNamed("\(filePrefix)" + "\(i)"))
    }
    
    sprite = SKSpriteNode(texture:spriteArray[0])
    originalHeight = sprite.size.height
    
    //physicsBody traits
    sprite.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sprite.size.width * 0.55, sprite.size.height))
    sprite.physicsBody!.dynamic = true
    sprite.physicsBody!.allowsRotation = false
    sprite.physicsBody?.categoryBitMask = playerCategory //belongs to this category
    sprite.physicsBody?.contactTestBitMask = killCategory | groundCategory
    sprite.physicsBody?.collisionBitMask = 0 | groundCategory | obstacleCategory
    
    //frame-by-frame settings
    let animateAction = SKAction.animateWithTextures(spriteArray, timePerFrame: 0.075, resize: true, restore: true)
    runningAction = SKAction.repeatActionForever(animateAction)
    sprite.runAction(runningAction)
    
    let jumpTexture = SKTexture(imageNamed: ("\(filePrefix)" + "Jump"))
    let jumpAnimation = SKAction.setTexture(jumpTexture, resize: true)
    jumpAction = jumpAnimation
  }
}