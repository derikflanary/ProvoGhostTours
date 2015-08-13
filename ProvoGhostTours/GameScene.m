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

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
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
        
        [self rotateWheels];
        [self addGhost];
    }
    return self;
}

- (void)addGhost{
    //create sprite
    SKSpriteNode *ghost = [SKSpriteNode spriteNodeWithImageNamed:@"Ghost2"];
    
    //Determine where to spawn ghost along X axis
    int minX = ghost.size.width / 2;
    int maxX = self.frame.size.width - ghost.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the ghost slightly off-screen along the top edge,
    // and along a random position along the X axis as calculated above
    ghost.position = CGPointMake(actualX, self.frame.size.height + ghost.size.height/2);
    [self addChild:ghost];
    
    // Determine speed of the ghost
    int minDuration = 4.0;
    int maxDuration = 6.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, 0) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [ghost runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addGhost];
    }
}


//animations
- (void)rotateWheels{
    //create repeating rotation for wheels
    SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 5.0];
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    [self.backWheel runAction:repeat];
    [self.frontWheel runAction:repeat];
}

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
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.movingBackground.position.x <= - 2600) {
        self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    }else{
        self.movingBackground.position = CGPointMake(self.movingBackground.position.x-1, self.movingBackground.position.y);
    }
}

@end
