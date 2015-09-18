//
//  Ghost.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/18/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "Ghost.h"

@implementation Ghost

- (void)collidedWithFlashlight:(NSTimeInterval)delta Super:(BOOL)superlight{
    
    if (!superlight) {
        if (self.alpha < 1) {
            self.alpha = self.alpha + delta/2.25;
        }
    }else{
        if (self.alpha < 1) {
            self.alpha = self.alpha + delta/1.10;
        }
    }
    
}

- (void)initialCollisionWithLight{
    if (self.alpha < .05) {
        self.alpha = .05;
    }

}

- (void)die{
    [self runAction:[SKAction stop]];
    SKAction *grow = [SKAction resizeToWidth:self.size.width * 1.5 duration:.075];
    SKAction *shrink = [SKAction resizeToWidth:self.size.width * .75 duration:.075];
    SKAction *die = [SKAction fadeOutWithDuration:.15];
    SKAction *remove = [SKAction removeFromParent];
    [self runAction:die];
    [self runAction:[SKAction sequence:@[grow, shrink, die, remove]]];
}

@end
