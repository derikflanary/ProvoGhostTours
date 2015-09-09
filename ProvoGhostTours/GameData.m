//
//  GameData.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/9/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameData.h"

@interface GameData () <NSCoding>

@end

@implementation GameData

static NSString* const GTGameDataHighScoreKey = @"highScore";
static NSString* const GTGameDataTotalCoinsKey = @"totalCoins";


+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

- (instancetype)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if (self) {
        _highScore = [decoder decodeDoubleForKey: GTGameDataHighScoreKey];
        _coins = [decoder decodeDoubleForKey: GTGameDataTotalCoinsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeDouble:self.highScore forKey: GTGameDataHighScoreKey];
    [encoder encodeDouble:self.coins forKey: GTGameDataTotalCoinsKey];
}

+ (instancetype)loadInstance{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[GameData alloc] init];
}

+ (NSString*)filePath{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}


- (void)reset{
    self.score = 0;
}

- (void)save{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
}

@end
