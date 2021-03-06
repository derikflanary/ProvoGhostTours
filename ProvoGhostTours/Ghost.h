//
//  Ghost.h
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/18/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Ghost : SKSpriteNode

@property (nonatomic) NSTimeInterval timeContacted;
@property (nonatomic, assign) BOOL isContacted;
@property (nonatomic, assign) BOOL enflamed;

- (void)collidedWithFlashlight:(NSTimeInterval)delta Super:(BOOL)superlight;
- (void)initialCollisionWithLight;
- (void)die;
@end
