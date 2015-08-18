//
//  Ghost.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/18/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "Ghost.h"

@implementation Ghost

- (void)collidedWithFlashlight{
    if (self.alpha < 1) {
        self.alpha = self.alpha + .01;
    }
    
}

@end
