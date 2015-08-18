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

@end

@implementation GameScene

static const uint32_t flashlightCategory     =  0x1 << 0;
static const uint32_t ghostCategory        =  0x1 << 1;
static const uint32_t bikerCategory         = 0x1 << 2;

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        [self startGame];
        // 3
        self.backgroundColor = [SKColor blackColor];
        
        
    }
    return self;
}

- (void)startGame{
    // 4
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"Sky2"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
    
    self.movingBackground = [SKSpriteNode spriteNodeWithImageNamed:@"All Buildings"];
    self.movingBackground.size = CGSizeMake(2562, self.frame.size.height);
    self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    self.movingBackground.anchorPoint = CGPointZero;
    [self addChild:self.movingBackground];
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_body_a.png"];
    self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height - 7);
    [self addChild:self.player];
    
    self.backWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.backWheel.position = CGPointMake(self.player.position.x - 20, self.player.position.y - 10);
    [self addChild:self.backWheel];
    
    self.frontWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.frontWheel.position = CGPointMake(self.player.position.x + 20, self.player.position.y - 10);
    [self addChild:self.frontWheel];
    
    self.biker = [SKSpriteNode spriteNodeWithImageNamed:@"Biker1_a"];
    self.biker.position = CGPointMake(self.player.position.x, self.player.position.y + self.biker.size.height / 4);
    self.biker.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.biker.size];
    self.biker.physicsBody.categoryBitMask = bikerCategory;
    self.biker.physicsBody.contactTestBitMask = ghostCategory;
    self.biker.physicsBody.collisionBitMask = 0;
    [self addChild:self.biker];
    self.bikerAnimation = [self animationFromPlist:@"bikerAnimation"];
    
    self.centerPoint = [SKNode new];
    self.centerPoint.position = self.player.position;
    [self addChild:self.centerPoint];
    
    self.light = [SKSpriteNode spriteNodeWithImageNamed:@"flashlight2"];
    self.light.alpha = 0.25;
    self.light.position = CGPointMake(0, self.light.size.height/2);
    [self.centerPoint addChild:self.light];
    
    self.light.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.light.size];
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
    
    //create Physics for collisions
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    
    //Set up arrays for ghost spawning and deleting
    self.ghostArray = [NSMutableArray array];
    self.contactedGhostArray = [NSMutableArray array];
    
    //Add Bike Sound Effect
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"bikePedal" withExtension:@"caf"];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer play];
    
    self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
    
    self.score = 0;
    
    [self rotateWheels];
    [self.biker runAction:self.bikerAnimation];
    
    self.minDuration = 5;
    self.maxDuration = 10;
    [self addGhost];
}

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
    
    ghost.alpha = 0.0;
    
    [self addChild:ghost];
    
    // Determine speed of the ghost
    
    int rangeDuration = self.maxDuration - self.minDuration;
    int actualDuration = (arc4random() % rangeDuration) + self.minDuration;
    
    // Create the actions
    SKAction *actionMove = [SKAction moveTo:self.biker.position duration:actualDuration];
    [ghost runAction:actionMove];
    SKAction *actionMoveDone = [SKAction removeFromParent];
//    [ghost runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

#pragma mark Update Methods
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    if (self.gameover) {
        return;
    }
    
    //Set time between spawns
    int minSpawn = 1.0;
    int maxSpawn = 3.0;

    if (self.score < 100) {
        minSpawn = 3;
        maxSpawn = 10;
        self.minDuration = 9;
        self.maxDuration = 13;
    }else if (self.score < 200){
        minSpawn = 2;
        maxSpawn = 7;
        self.minDuration = 8;
        self.maxDuration = 12;
    }else if (self.score < 300){
        minSpawn = 1;
        maxSpawn = 5;
        self.minDuration = 6;
        self.maxDuration = 10;
    }else if (self.score < 400){
        minSpawn = 1;
        maxSpawn = 3;
        self.minDuration = 5;
        self.maxDuration = 9;
    }else{
        minSpawn = 1;
        maxSpawn = 2;
        self.minDuration = 4;
        self.maxDuration = 9;
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
    /* Called before each frame is rendered */
    if (self.movingBackground.position.x <= - 2600) {
        self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    }else{
        self.movingBackground.position = CGPointMake(self.movingBackground.position.x-1, self.movingBackground.position.y);
    }

    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    if ([self.contactedGhostArray count] > 0) {
        [self updateGhostInLight];
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateGhostInLight{
    //Update the ghost if it is in the light
    if (self.gameover) {
        return;
    }
        NSMutableArray *removedGhostsArray = [NSMutableArray array];
        for (Ghost *ghost in self.contactedGhostArray) {
            if (ghost.alpha >= .9) {
                [ghost removeFromParent];
                [self.ghostArray removeObject:ghost];
                [removedGhostsArray addObject:ghost];
                self.score += 10;
                [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %ld", (long)self.score]];
                NSLog(@"%lu", (long)self.score);
                
                [self runAction:self.ghostSound];
            }else{
                [ghost collidedWithFlashlight];
            }
        }
        [self.contactedGhostArray removeObjectsInArray:removedGhostsArray];
}

#pragma mark Animations
- (void)rotateWheels{
    //create repeating rotation for wheels
    SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 5.0];
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


- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
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

- (void)flashlight:(SKSpriteNode *)flashlight didCollideWithGhost:(Ghost *)ghost {
    if (ghost.alpha < .4) {
        ghost.alpha = .4;
    }
    
    NSUInteger indexOfGhost = [self.ghostArray indexOfObject:ghost];
    ghost.isContacted = YES;
    [self.contactedGhostArray addObject:[self.ghostArray objectAtIndex:indexOfGhost]];
    
}

- (void)flashlight:(SKSpriteNode *)flashlight didStopCollidingWithGhost:(Ghost *)ghost{

    ghost.isContacted = NO;
    [self.contactedGhostArray removeObject:ghost];
}

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
    
    // 2
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
    NSLog(@"A is %u", contact.bodyA.categoryBitMask);
    NSLog(@"B is %u", contact.bodyB.categoryBitMask);
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
    
    // 2
    if ((firstBody.categoryBitMask & flashlightCategory) != 0 &&
        (secondBody.categoryBitMask & ghostCategory) != 0)
    {
        if ([secondBody.node isKindOfClass:[Ghost class]]) {
            [self flashlight:(SKSpriteNode *)firstBody.node didStopCollidingWithGhost:(Ghost *)secondBody.node];
        }
       
    }
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
