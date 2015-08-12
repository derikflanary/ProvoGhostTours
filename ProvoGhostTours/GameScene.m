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
        self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height);
        [self addChild:self.player];
        
    }
    return self;
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
