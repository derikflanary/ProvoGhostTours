//
//  GameData.h
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/9/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject

@property (assign, nonatomic) long score;
@property (assign, nonatomic) long highScore;
@property (nonatomic, assign) int flashbangs;
@property (nonatomic, assign) long coins;

+ (instancetype)sharedGameData;
- (void)reset;
-(void)save;
@end
