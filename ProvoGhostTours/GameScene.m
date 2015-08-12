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
    }
    return self;
}

- (void)rotateWheels{
    //create repeating rotation for wheels
    SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 5.0];
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    [self.backWheel runAction:repeat];
    [self.frontWheel runAction:repeat];
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
