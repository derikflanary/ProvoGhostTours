//
//  GameScene.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameScene.h"
#import "Ghost.h"
#import <AVFoundation/AVFoundation.h>

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) SKSpriteNode *biker;
@property (nonatomic) SKSpriteNode *movingBackground;
@property (nonatomic) SKSpriteNode *backWheel;
@property (nonatomic) SKSpriteNode *frontWheel;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastTreeSpawnInterval;
@property (nonatomic) SKSpriteNode *light;
@property (nonatomic) SKNode *centerPoint;
@property (nonatomic) Ghost *contactedGhost;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) NSMutableArray *ghostArray;
@property (nonatomic, strong) NSMutableArray *contactedGhostArray;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKAction *ghostSound;
@property (strong, nonatomic) SKAction *bikerAnimation;
@property (nonatomic, assign) int minDuration;
@property (nonatomic, assign) int maxDuration;
@property (nonatomic, assign) BOOL gameover;
@property (nonatomic, assign) BOOL gameStart;
@property (nonatomic, assign) BOOL firstPlay;
@property (nonatomic) SKLabelNode *highscoreLabel;
@property (nonatomic) SKLabelNode *titleLabel;
@property (nonatomic) SKSpriteNode *tree;
@property (nonatomic) SKSpriteNode *detector;
@property (nonatomic) NSTimeInterval delta;

@end

@implementation GameScene

static const uint32_t flashlightCategory     =  0x1 << 0;
static const uint32_t ghostCategory        =  0x1 << 1;
static const uint32_t bikerCategory         = 0x1 << 2;

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        // 3
        self.backgroundColor = [SKColor blackColor];
        self.gameStart = NO;
        
        [self addMainSprites];
        //create Physics for collisions
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //Add Bike Sound Effect
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"bikePedal" withExtension:@"caf"];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = -1;
        [self.audioPlayer play];
        
        self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
        
    }
    return self;
}

#pragma mark - Start Screen

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [self addStartScreenButtons];
}

- (void)addStartScreenButtons{
    
    self.titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.titleLabel.text = @"Provo Ghost Tours";
    self.titleLabel.fontSize = 36;
    self.titleLabel.zPosition = 4;
    self.titleLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 80);
    
    [self.titleLabel setScale:0.1];
    [self addChild:self.titleLabel];
    [self.titleLabel runAction:[SKAction scaleTo:1.0 duration:0.5]];

    UIButton *startGameButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMidY(self.frame) + 20, self.frame.size.width, 50)];
    [startGameButton setTitle:@"Play" forState:UIControlStateNormal];
    [startGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startGameButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [startGameButton setTintColor:[UIColor whiteColor]];
    startGameButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:32];
    [startGameButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    startGameButton.tag = 200;
    [self.view addSubview:startGameButton];
    
    UIButton *rateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(startGameButton.frame) + 40, self.frame.size.width, 50)];
    [rateButton setTitle:@"Rate" forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [rateButton setTintColor:[UIColor whiteColor]];
    rateButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:14];
    [rateButton addTarget:self action:@selector(rateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    rateButton.tag = 100;
    [self.view addSubview:rateButton];
    
    NSInteger highscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    self.highscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.highscoreLabel.text = [NSString stringWithFormat:@"High Score: %lu", (long)highscore];
    self.highscoreLabel.fontSize = 14;
    self.highscoreLabel.zPosition = 4;
    self.highscoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.titleLabel.position.y - 40);
    [self.highscoreLabel setScale:0.1];
    [self addChild:self.highscoreLabel];
    [self.highscoreLabel runAction:[SKAction scaleTo:1 duration:.5]];

}

#pragma mark - Main Scene Setup

- (void)addMainSprites{
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"Sky2"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
    
    self.movingBackground = [SKSpriteNode spriteNodeWithImageNamed:@"All Buildings"];
    self.movingBackground.size = CGSizeMake(2562, self.frame.size.height);
    self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    self.movingBackground.anchorPoint = CGPointZero;
    self.movingBackground.zPosition = 1;
    [self addChild:self.movingBackground];
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_body_a.png"];
    self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height - 7);
    self.player.zPosition = 2;
    [self addChild:self.player];
    
    self.backWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.backWheel.position = CGPointMake(self.player.position.x - 20, self.player.position.y - 10);
    self.backWheel.zPosition = 2;
    [self addChild:self.backWheel];
    
    self.frontWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.frontWheel.position = CGPointMake(self.player.position.x + 20, self.player.position.y - 10);
    self.frontWheel.zPosition = 2;
    [self addChild:self.frontWheel];
    
    self.biker = [SKSpriteNode spriteNodeWithImageNamed:@"Biker1_a"];
    self.biker.position = CGPointMake(self.player.position.x, self.player.position.y + self.biker.size.height / 4);
    self.biker.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.biker.size];
    self.biker.physicsBody.categoryBitMask = bikerCategory;
    self.biker.physicsBody.contactTestBitMask = ghostCategory;
    self.biker.physicsBody.collisionBitMask = 0;
    self.biker.zPosition = 2;
    [self addChild:self.biker];
    self.bikerAnimation = [self animationFromPlist:@"bikerAnimation"];
    
    [self rotateWheels];
    [self.biker runAction:self.bikerAnimation];
    [self addTreeAtX:self.frame.size.width - 100];
}

- (void)startGame{
    
    if (!self.firstPlay) {
        [self addMainSprites];
        [self.audioPlayer play];
        
        //create Physics for collisions
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    self.firstPlay = NO;
    self.gameStart = YES;
    
    self.centerPoint = [SKNode new];
    self.centerPoint.position = self.player.position;
    [self addChild:self.centerPoint];
    
    self.light = [SKSpriteNode spriteNodeWithImageNamed:@"flashlight2"];
    self.light.alpha = 0.25;
    self.light.position = CGPointMake(0, self.light.size.height/2);
    [self.centerPoint addChild:self.light];
    self.light.zPosition = 2;
    
    //create a physics body for the light's shape
    CGFloat offsetX = self.light.frame.size.width/2;
    CGFloat offsetY = self.light.frame.size.height/2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (([[UIScreen mainScreen] scale] == 2.0)) {
        CGPathMoveToPoint(path, NULL, 154 - offsetX, 325 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 324 - offsetY);
        CGPathAddLineToPoint(path, NULL, 59 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 98 - offsetX, 1 - offsetY);
        CGPathCloseSubpath(path);
    }else if (([[UIScreen mainScreen] scale] == 3.0)){
        CGPathMoveToPoint(path, NULL, 231 - offsetX, 415 - offsetY);
        CGPathAddLineToPoint(path, NULL, -1 - offsetX, 413 - offsetY);
        CGPathAddLineToPoint(path, NULL, 83 - offsetX, -1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 145 - offsetX, 3 - offsetY);
    }else{
        CGPathMoveToPoint(path, NULL, 76 - offsetX, 168 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 167 - offsetY);
        CGPathAddLineToPoint(path, NULL, 31 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 50 - offsetX, 0 - offsetY);
    }
    
    self.light.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    self.light.physicsBody.dynamic = YES;
    self.light.physicsBody.categoryBitMask = flashlightCategory;
    self.light.physicsBody.contactTestBitMask = ghostCategory;
    self.light.physicsBody.collisionBitMask = 0;
    self.light.physicsBody.usesPreciseCollisionDetection = YES;
    
    float margin = 10;
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.scoreLabel.text = @"Score: 0";
    self.scoreLabel.fontSize = [self convertFontSize:14];
    self.scoreLabel.zPosition = 4;
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.scoreLabel.position = CGPointMake(margin, margin);
    [self addChild:self.scoreLabel];
    
//    self.detector = [SKSpriteNode spriteNodeWithImageNamed:@"redcircle"];
//    self.detector.position = CGPointMake(self.biker.position.x + 20, self.biker.position.y);
//    self.detector.zPosition = 2;
//    [self addChild:self.detector];
    
    //Set up arrays for ghost spawning and deleting
    self.ghostArray = [NSMutableArray array];
    self.contactedGhostArray = [NSMutableArray array];
    
    self.score = 0;
    
    self.minDuration = 8;
    self.maxDuration = 10;
    [self addGhost];
}

#pragma mark - Start Screen Button Methods

- (void)playButtonPressed:(id)sender{
    
    self.gameStart = YES;
    self.firstPlay = YES;
    [self startGame];
    [[self.view viewWithTag:200] removeFromSuperview];
    [[self.view viewWithTag:100] removeFromSuperview];
    [self.highscoreLabel removeFromParent];
    [self.titleLabel removeFromParent];
}

- (void)rateButtonPressed:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1031990080"]];
}


#pragma mark - Ghost Methods

- (void)addGhost{
    
    //Determine where to spawn ghost along X axis
    int minX = -100;
    int maxX = self.frame.size.width + 100;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    Ghost *ghost = [Ghost spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Ghost2"]];
    [self.ghostArray addObject:ghost];
    //create sprite
    if (actualX > self.frame.size.width/2) {
        ghost.texture = [SKTexture textureWithImageNamed:@"Ghost2right"];
    }
    
    //Determine a random Y if the spawn's X is off screen
    int minY = 50;
    int maxY = self.frame.size.height + 10;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the ghost slightly off-screen along the top edge,
    // and along a random position along the X axis as calculated above
    if (actualX < 0 || actualX > self.frame.size.width) {
        ghost.position = CGPointMake(actualX, actualY);
    }else{
        
        ghost.position = CGPointMake(actualX, self.frame.size.height + ghost.size.height/2);
    }
    
    ghost.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ghost.size];
    ghost.physicsBody.dynamic = YES;
    ghost.physicsBody.categoryBitMask = ghostCategory;
    ghost.physicsBody.contactTestBitMask = flashlightCategory;
    ghost.physicsBody.contactTestBitMask = bikerCategory;
    ghost.physicsBody.collisionBitMask = 0;
    ghost.zPosition = 2;
    
    ghost.alpha = 0.0;
    
    [self addChild:ghost];
    
    // Determine speed of the ghost
    
    int rangeDuration = self.maxDuration - self.minDuration;
    int actualDuration = (arc4random() % rangeDuration) + self.minDuration;
    
    // Create the actions
    SKAction *actionMove = [SKAction moveTo:self.biker.position duration:actualDuration];
    [ghost runAction:actionMove];

}

- (void)updateGhostInLight:(NSTimeInterval)delta{
    //Update the ghost if it is in the light
    if (self.gameover) {
        return;
    }
    NSMutableArray *removedGhostsArray = [NSMutableArray array];
    for (Ghost *ghost in self.contactedGhostArray) {
        if (ghost.alpha >= .9) {
            SKAction *grow = [SKAction resizeToWidth:ghost.size.width * 1.5 duration:.075];
            SKAction *shrink = [SKAction resizeToWidth:ghost.size.width * .75 duration:.075];
            SKAction *die = [SKAction fadeOutWithDuration:.15];
            SKAction *remove = [SKAction removeFromParent];
            
            [self.ghostArray removeObject:ghost];
            [removedGhostsArray addObject:ghost];
            self.score += 10;
            [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %ld", (long)self.score]];
            [ghost runAction:[SKAction sequence:@[grow, shrink, remove]]];
            [ghost runAction:die];
            [self runAction:self.ghostSound];
        }else{
            [ghost collidedWithFlashlight:delta];
        }
    }
    [self.contactedGhostArray removeObjectsInArray:removedGhostsArray];
}

#pragma mark - Tree Methods

- (void)addTreeAtX:(CGFloat)X{
    int minZ = 0;
    int maxZ = 4;
    int rangeZ = maxZ - minZ;
    int actualZ = (arc4random() % rangeZ) + minZ;
    NSLog(@"%d", actualZ);

    self.tree = [SKSpriteNode spriteNodeWithImageNamed:@"Tree1"];
    self.tree.position = CGPointMake(X, 0);
    self.tree.anchorPoint = CGPointZero;
    self.tree.zPosition = actualZ;
    [self addChild:self.tree];
}

#pragma mark - Detector Methods

//- (void)updateDistanceFromDetector{
//    CGFloat smallestDist = 300.0;
//    for (Ghost *ghost in self.ghostArray) {
//        CGFloat distance = [self SDistanceBetweenPoints:ghost.position andSecond:self.biker.position];
//        if (distance < smallestDist) {
//            smallestDist = distance;
//        }
//    }
//    
//    float percent = 1 - (smallestDist/350);
//    if (percent < 1) {
//        [self animateDetectorWithPercent:percent];
//    }
//    
//}

- (CGFloat)SDistanceBetweenPoints:(CGPoint)first andSecond:(CGPoint)second{
    return hypotf(second.x - first.x, second.y - first.y);
}

//- (void)animateDetectorWithPercent:(CGFloat)percent{
//    float duration = 1 - percent;
//    int count = 1 / duration;
//    SKAction *grow = [SKAction scaleBy:2 duration:duration/2];
//    SKAction *shrink = [SKAction scaleBy:0.5 duration:duration/2];
//    SKAction *brighten = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1 duration:duration/2];
//    SKAction *darken = [SKAction colorizeWithColor:[UIColor darkGrayColor] colorBlendFactor:1 duration:duration/2];
//    [self.detector runAction:[SKAction sequence:@[grow, shrink]]];
//    [self.detector runAction:[SKAction repeatAction:[SKAction sequence:@[grow, shrink]] count:count]];
////    [self.detector runAction:[SKAction repeatActionForever:[SKAction sequence:@[brighten, darken]]]];
//}

#pragma mark Update Methods
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    if (self.gameover) {
        return;
    }
    
    if (!self.gameStart) {
        return;
    }
    
    //Set time between spawns and speeds
    int minSpawn = 2.0;
    int maxSpawn = 5.0;

    if (self.score < 100) {
        minSpawn = 5;
        maxSpawn = 10;
        self.minDuration = 9;
        self.maxDuration = 13;
    }else if (self.score < 200){
        minSpawn = 4;
        maxSpawn = 9;
        self.minDuration = 8;
        self.maxDuration = 12;
    }else if (self.score < 300){
        minSpawn = 3;
        maxSpawn = 7;
        self.minDuration = 7;
        self.maxDuration = 12;
    }else if (self.score < 400){
        minSpawn = 3;
        maxSpawn = 6;
        self.minDuration = 7;
        self.maxDuration = 11;
    }else{
        minSpawn = 3;
        maxSpawn = 5;
        self.minDuration = 7;
        self.maxDuration = 10;
    }
    
    int rangeSpawn = maxSpawn - minSpawn;
    int actualSpawn = (arc4random() % rangeSpawn) + minSpawn;
    
    //spawn new ghost if time between spawns has happended
    self.lastSpawnTimeInterval += timeSinceLast;
    
    if (self.lastSpawnTimeInterval > actualSpawn) {
        self.lastSpawnTimeInterval = 0;
        [self addGhost];
    }
    
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.gameover) {
        return;
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;

    /* Called before each frame is rendered */
    if (self.movingBackground.position.x <= - 2600) {
        self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    }else{
        self.movingBackground.position = CGPointMake(self.movingBackground.position.x - 1, self.movingBackground.position.y);
    }
    
    if (self.tree.position.x <= -250) {
        [self.tree removeFromParent];
        int actualSpawn = (arc4random() % 200) + 10;
        [self addTreeAtX:self.view.frame.size.width + actualSpawn];
    }else{
        self.tree.position = CGPointMake(self.tree.position.x - 1, self.tree.position.y);
    }

    // Handle time delta.
        if (timeSinceLast > .02) {
        self.lastUpdateTimeInterval = currentTime;
        if ([self.contactedGhostArray count] > 0) {
            [self updateGhostInLight:timeSinceLast];
        }
    }
    
//    CFTimeInterval delta = currentTime - self.delta;
//    if (delta >= 1) {
//        self.delta = currentTime;
//        [self updateDistanceFromDetector];
//    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

#pragma mark - Animations
- (void)rotateWheels{
    //create repeating rotation for wheels
    SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 4.0];
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    [self.backWheel runAction:repeat];
    [self.frontWheel runAction:repeat];
}

- (void)rotateNode:(SKSpriteNode *)nodeA toFaceNode:(SKSpriteNode *)nodeB {
    
    double angle = atan2(nodeB.position.y - nodeA.position.y, nodeB.position.x - nodeA.position.x);
    
    if (nodeA.zRotation < 0) {
        nodeA.zRotation = nodeA.zRotation + M_PI * 2;
    }
    
    [nodeA runAction:[SKAction rotateToAngle:angle duration:0]];
}

- (SKAction *)animationFromPlist:(NSString *)animPlist{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:animPlist ofType:@"plist"]; // 1
    NSArray *animImages = [NSArray arrayWithContentsOfFile:plistPath]; // 2
    NSMutableArray *animFrames = [NSMutableArray array]; // 3
    for (NSString *imageName in animImages) { // 4
        [animFrames addObject:[SKTexture textureWithImageNamed:imageName]]; // 5
    }
    
    float framesOverOneSecond = 1.0f/(float)[animFrames count];
    
    return [SKAction repeatActionForever:[SKAction animateWithTextures:animFrames timePerFrame:framesOverOneSecond resize:NO restore:YES]]; // 6
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (self.gameover) {
        return;
    }
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = atan2f(dY, dX) + 1.571f;
        [self.centerPoint runAction:[SKAction rotateToAngle:angle duration:0.0 shortestUnitArc:YES]];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.gameover) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = (atan2f(dY, dX)) + 1.571f;
        self.centerPoint.zRotation = angle;
    }
}

#pragma mark collision methods

- (void)didBeginContact:(SKPhysicsContact *)contact{
    if (self.gameover) {
        return;
    }
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    
    if ((firstBody.categoryBitMask & flashlightCategory) != 0 &&
        (secondBody.categoryBitMask & ghostCategory) != 0)
    {
        if ([secondBody.node isKindOfClass:[Ghost class]]) {
                [self flashlight:(SKSpriteNode *)firstBody.node didCollideWithGhost:(Ghost *)secondBody.node];
        }
    }
    if ((firstBody.categoryBitMask & ghostCategory) != 0 &&
        (secondBody.categoryBitMask & bikerCategory) != 0)
    {
        Ghost *ghost = (Ghost *)firstBody.node;
        ghost.alpha = .8;
        [self ghostCollidesWithBiker];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact{
    if (self.gameover) {
        return;
    }
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & flashlightCategory) != 0 &&
        (secondBody.categoryBitMask & ghostCategory) != 0)
    {
        if ([secondBody.node isKindOfClass:[Ghost class]]) {
            [self flashlight:(SKSpriteNode *)firstBody.node didStopCollidingWithGhost:(Ghost *)secondBody.node];
        }
       
    }
}

- (void)flashlight:(SKSpriteNode *)flashlight didCollideWithGhost:(Ghost *)ghost {
    if (ghost.alpha < .05) {
        ghost.alpha = .05;
    }
    
    ghost.isContacted = YES;
    [self.contactedGhostArray addObject:ghost];
}

- (void)flashlight:(SKSpriteNode *)flashlight didStopCollidingWithGhost:(Ghost *)ghost{
    
    ghost.isContacted = NO;
    [self.contactedGhostArray removeObject:ghost];
}

- (void)ghostCollidesWithBiker{
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOverLabel.text = @"Game Over!";
    gameOverLabel.fontSize = 48;
    gameOverLabel.zPosition = 4;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame));
    
    [gameOverLabel setScale:0.1];
    [self addChild:gameOverLabel];
    [gameOverLabel runAction:[SKAction scaleTo:1.0 duration:0.5]];
    
    UIButton *restartButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMidY(self.frame) + 20, self.frame.size.width, 50)];
    [restartButton setTitle:@"Try Again" forState:UIControlStateNormal];
    [restartButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [restartButton setTintColor:[UIColor whiteColor]];
    restartButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:14];
    [restartButton addTarget:self action:@selector(restartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    restartButton.tag = 321;
    [self.view addSubview:restartButton];
    
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    if (self.score > highScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        highScore = self.score;
    }
    
    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    highScoreLabel.text = [NSString stringWithFormat:@"High Score: %lu", (long)highScore];
    highScoreLabel.fontSize = 20;
    highScoreLabel.zPosition = 4;
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), gameOverLabel.position.y + 50);
    [highScoreLabel setScale:0.1];
    [self addChild:highScoreLabel];
    [highScoreLabel runAction:[SKAction scaleTo:1 duration:.5]];
    
    [self.audioPlayer stop];
    
    self.gameover = YES;

}

- (void) restartButtonPressed:(id)sender{
    [self removeAllChildren];
    [self removeAllActions];
    self.gameover = NO;
    [[self.view viewWithTag:321] removeFromSuperview];
    
    [self startGame];
}

- (float)convertFontSize:(float)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}


@end
