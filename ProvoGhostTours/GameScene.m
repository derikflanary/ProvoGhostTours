//
//  GameScene.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) SKSpriteNode *movingBackground;
@property (nonatomic) SKSpriteNode *backWheel;
@property (nonatomic) SKSpriteNode *frontWheel;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKSpriteNode *light;
@property (nonatomic) SKNode *centerPoint;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor blackColor];
        
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
        
        self.centerPoint = [SKNode new];
        self.centerPoint.position = self.player.position;
        [self addChild:self.centerPoint];
        
        self.light = [SKSpriteNode spriteNodeWithImageNamed:@"flashlight"];
        self.light.position = CGPointMake(0, self.light.size.height/2);
//        self.light.zRotation = M_PI;
        [self.centerPoint addChild:self.light];
        
//        NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
//        SKEmitterNode *snowParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
//        snowParticle.particlePosition = self.player.position;
//        
//        
//        [self addChild:snowParticle];
        
        
//        //setup a fire emitter
//        NSString *fireEmmitterPath = [[NSBundle mainBundle] pathForResource:@"light" ofType:@"scnp"];
//        SKEmitterNode *fireEmmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:fireEmmitterPath];
//        fireEmmitter.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 200);
//        fireEmmitter.name = @"fireEmmitter";
//        fireEmmitter.zPosition = 1;
//        fireEmmitter.targetNode = self;
//        [self addChild: fireEmmitter];
        
                
        [self rotateWheels];
        [self addGhost];
    }
    return self;
}

- (void)addGhost{
    
    //Determine where to spawn ghost along X axis
    int minX = -100;
    int maxX = self.frame.size.width + 100;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    SKSpriteNode *ghost = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Ghost2"]];
    //create sprite
    if (actualX > self.frame.size.width/2) {
        ghost.texture = [SKTexture textureWithImageNamed:@"Ghost2right"];
//        double angle = atan2(self.player.position.y - ghost.position.y, self.player.position.x - ghost.position.x);
//        ghost.zRotation = angle + M_PI/4;
    }else{
//        double angle = atan2(self.player.position.y - ghost.position.y, self.player.position.x - ghost.position.x);
//        ghost.zRotation = angle - M_PI/4;
    }
    
    //Determine a random Y if the spawn's X is off screen
    int minY = self.frame.size.height - 200;
    int maxY = self.frame.size.height + 10;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the ghost slightly off-screen along the top edge,
    // and along a random position along the X axis as calculated above
    if (actualX < 0 || actualX > self.frame.size.width) {
        ghost.position = CGPointMake(actualX, actualY);
        NSLog(@"%d", actualY);
    }else{
        ghost.position = CGPointMake(actualX, self.frame.size.height + ghost.size.height/2);
    }
    
    ghost.alpha = 0.4;
    
    [self addChild:ghost];
    
    // Determine speed of the ghost
    int minDuration = 8.0;
    int maxDuration = 11.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:self.player.position duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [ghost runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    //Set time between spawns
    int minSpawn = 6.0;
    int maxSpawn = 10.0;
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
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

//animations
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

//Vector Methods
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

    // Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = atan2f(dY, dX) + 1.571f;
        [self.centerPoint runAction:[SKAction rotateToAngle:angle duration:0.5 shortestUnitArc:YES]];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = (atan2f(dY, dX)) + 1.571f;
        self.centerPoint.zRotation = angle;
    }
}

@end
