//
//  Ghost.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/18/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "Ghost.h"

@implementation Ghost

- (void)collidedWithFlashlight:(NSTimeInterval)delta{
    if (self.alpha < 1) {
        self.alpha = self.alpha + delta/2.5;
    }
    
}

@end
