//
//  GameScene.swift
//  ballAttack
//
//  Created by Szi Gabor on 3/26/16.
//  Copyright (c) 2016 nuSyntax. All rights reserved.
//

import SpriteKit
import CoreMotion


struct physicsCatagory {
    
    static let enemy : UInt32 = 0x1 << 0
    static let smallBall : UInt32 = 0x1 << 1
    static let mainBall : UInt32 = 0x1 << 2
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    //public variables
    var mainBall =  SKSpriteNode (imageNamed: "ball")
    var enemyTimer = NSTimer()
    var hits = 0
    var gameStarted = false
    var score = 0
    var highScore = 0
    
    //ios developer tips dot com for fronts
    var tapToBeginLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var scoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var highScoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var fadeAnimation = SKAction()
    
    
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        let highScoreDefault = NSUserDefaults.standardUserDefaults()
        
        if highScoreDefault.valueForKey("highScore") != nil {
            
            highScore = highScoreDefault.valueForKey("highScore") as! Int
            
            highScoreLabel.text = "HighScore : \(highScore)"
        }
        
        tapToBeginLabel.text = "Tap To Begin"
        tapToBeginLabel.fontSize = 34
        tapToBeginLabel.position = CGPoint (x:scene!.frame.width / 2, y: frame.height / 2) //center of the screen
        tapToBeginLabel.fontColor = UIColor.whiteColor()
        tapToBeginLabel.zPosition = 2.0
        self.addChild(tapToBeginLabel)
        
        fadeAnimation = SKAction.sequence([SKAction.fadeInWithDuration(1.0), SKAction.fadeOutWithDuration(1.0)])
        tapToBeginLabel.runAction(SKAction.repeatActionForever(fadeAnimation))
        
        
        highScoreLabel.text = "HighScore \(highScore)"
        highScoreLabel.fontSize = 30
        highScoreLabel.position = CGPoint (x:scene!.frame.width / 2, y: frame.height / 1.3) //center of the screen
        highScoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) //dark grey color
        highScoreLabel.alpha = 0  //highscore lable will be hiden
        self.addChild(highScoreLabel)
        
        
        scoreLabel.alpha = 0
        scoreLabel.fontSize = 35
        scoreLabel.position = CGPoint (x:scene!.frame.width / 2, y: frame.height / 1.3) //center of the screen
        scoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) //dark grey color
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        
        backgroundColor = UIColor.whiteColor()
        
        //set the size and position of the object (ball)
        mainBall.size = CGSize (width: 225, height: 225)
        mainBall.position = CGPoint (x:scene!.frame.width / 2, y: frame.height / 2)
        mainBall.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        mainBall.colorBlendFactor = 1.0
        
        
        //set the object to the foreground
        mainBall.zPosition = 1.0
        mainBall.physicsBody = SKPhysicsBody(circleOfRadius: mainBall.size.width/2)
        mainBall.physicsBody?.categoryBitMask = physicsCatagory.mainBall
        mainBall.physicsBody?.collisionBitMask = physicsCatagory.enemy
        mainBall.physicsBody?.contactTestBitMask = physicsCatagory.enemy
        mainBall.physicsBody?.affectedByGravity = false
        mainBall.physicsBody?.dynamic = false
        mainBall.name = "mainBall"
        self.addChild(mainBall)
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if ((firstBody.name == "enemy") && (secondBody.name == "smallBall"))  {
                
                collsionBullet(firstBody, smallBall: secondBody)
            }
                
            else if ((firstBody.name == "smallBall") && (secondBody.name == "enemy")){
                collsionBullet(secondBody, smallBall: firstBody)
                
            }
            else if ((firstBody.name == "mainBall") && (secondBody.name == "enemy")){
                collisionMain(secondBody)
                
            }
            else if((firstBody.name == "enemy") && (secondBody.name == "mainBall")){
                collisionMain(firstBody)
                
            }
        }
    }
    
    func collisionMain(enemy:SKSpriteNode) {
        
        
        if hits < 2 //number of lives
        {
            
            mainBall.runAction(SKAction.scaleBy(1.5, duration: 0.4))
            enemy.physicsBody?.affectedByGravity = true
            enemy.removeAllActions()
            mainBall.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.1), SKAction.colorizeWithColor(SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1)]))
            hits++
            enemy.removeFromParent()
            
        }
            
            //as soon as the game ends, run the code below
        else{
            
            enemy.removeFromParent()
            enemyTimer.invalidate()
            gameStarted = false
            
            scoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            tapToBeginLabel.runAction(SKAction.fadeInWithDuration(1.0))
            tapToBeginLabel.runAction(SKAction.repeatActionForever(fadeAnimation))
            highScoreLabel.runAction(SKAction.fadeInWithDuration(0.2))
            
            //save the High Score in the background using NSUserDefaults
            if score > highScore {
                
                let highScoreDefaut = NSUserDefaults.standardUserDefaults()
                highScore = score
                highScoreDefaut.setInteger(highScore, forKey: "highScore")
                highScoreLabel.text = "HighScore:\(highScore)"
                
            }
        }
    }
    
    
    func collsionBullet (enemy : SKSpriteNode, smallBall : SKSpriteNode){
        
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.mass = 5.0
        smallBall.physicsBody?.mass = 5.0
        
        enemy.removeAllActions()
        smallBall.removeAllActions()
        
        //after the enemy gets hit
        enemy.physicsBody?.contactTestBitMask = 0
        enemy.physicsBody?.collisionBitMask = 0
        enemy.name = nil
        
        
        score++ //everytime the enemy touches the ball the score goes up by 1
        scoreLabel.text = "\(score)"
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //to check if the game started
        
        if gameStarted == false {
            enemyTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("enemies"), userInfo: nil, repeats: true)
            gameStarted = true
            mainBall.runAction(SKAction.scaleTo(0.44, duration: 0.2))
            hits = 0
            
            tapToBeginLabel.removeAllActions() //is going to remove all the fading in & out for the label
            tapToBeginLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            highScoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            
            //allows the score label to appear in sequence. It'll wait for 1 sec then fade in
            scoreLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.fadeInWithDuration(1.0)]))
            
            //the score will reset to zero when the game starts up for the 1st time
            score = 0
            scoreLabel.text = "\(score)"
            
        }
            //once the game has started the game will run its normal functions
        else{
            
            for touch in touches {
                
                let location = touch.locationInNode(self)
                
                //create a new object when the user touches the screen
                var smallBall = SKSpriteNode (imageNamed: "ball")
                smallBall.position = mainBall.position
                smallBall.size = CGSize(width: 30, height: 30)
                smallBall.physicsBody = SKPhysicsBody(circleOfRadius:smallBall.size.width/2)
                smallBall.physicsBody?.affectedByGravity = false
                smallBall.color = UIColor(red: 0.1, green: 0.85, blue: 0.95, alpha: 1.0)
                smallBall.colorBlendFactor = 1.0
                
                //adding collision
                smallBall.physicsBody?.categoryBitMask = physicsCatagory.smallBall
                smallBall.physicsBody?.collisionBitMask = physicsCatagory.enemy
                smallBall.physicsBody?.contactTestBitMask = physicsCatagory.enemy
                smallBall.name = "smallBall"
                smallBall.physicsBody?.dynamic = true
                smallBall.physicsBody?.affectedByGravity = true
                
                var dx = CGFloat(location.x - mainBall.position.x)
                var dy = CGFloat(location.y - mainBall.position.y)
                
                let magnitude = sqrt(dx * dx + dy * dy)
                
                dx /= magnitude
                dy /= magnitude
                
                self.addChild(smallBall)
                
                let vector = CGVector(dx: 30.0 * dx, dy: 30.0 * dy)
                smallBall.physicsBody?.applyImpulse(vector)
                
            }
        }
    }
    
    func enemies(){
        
        //create enemies
        let enemy = SKSpriteNode (imageNamed:"ball")
        enemy.size = CGSize(width: 20.0, height: 20.0)
        enemy.color = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
        enemy.colorBlendFactor = 1.0
        
        //physics
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/2)
        enemy.physicsBody?.categoryBitMask = physicsCatagory.enemy
        enemy.physicsBody?.contactTestBitMask = physicsCatagory.smallBall | physicsCatagory.mainBall
        enemy.physicsBody?.collisionBitMask = physicsCatagory.smallBall | physicsCatagory.mainBall
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.dynamic = true // enemy is effected by gravity
        enemy.name = "enemy"
        
        
        //picks a random number from 0-3
        let randomNumberPosition = arc4random() % 4
        switch randomNumberPosition {
            
        case 0:
            
            enemy.position.x = 0
            
            //have the object appear randomly on the Y axis
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            
            self.addChild(enemy)
            
            break
            
        case 1:
            
            enemy.position.y = 0
            
            //have the object appear randomly on the Y axis
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            
            self.addChild(enemy)
            
            break
            
        case 2:
            
            enemy.position.y = frame.size.height
            
            //have the object appear randomly on the Y axis
            let positionX = arc4random_uniform(UInt32(frame.size.width))
            enemy.position.x = CGFloat(positionX)
            
            self.addChild(enemy)
            
            break
            
        case 3:
            
            enemy.position.x = frame.size.width
            
            //have the object appear randomly on the Y axis
            let positionY = arc4random_uniform(UInt32(frame.size.height))
            enemy.position.y = CGFloat(positionY)
            
            self.addChild(enemy)
            
            break
            
        default:
            
            break
            
        }
        //since the enemy arent moving to an object and staying static, use runAction method - move to the Mainball
        enemy.runAction(SKAction.moveTo(mainBall.position, duration: 3))
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
}

