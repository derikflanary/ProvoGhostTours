//
//  GameData.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/9/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameData.h"
#import "KeychainWrapper/KeychainWrapper.h"

@interface GameData () <NSCoding>

@end

@implementation GameData

static NSString* const GTGameDataHighScoreKey = @"highScore";
static NSString* const GTGameDataTotalCoinsKey = @"totalCoins";
static NSString* const GTGameDataCharacterKey = @"selectedCharacterIndex";
static NSString* const GTGameDataChecksumKey = @"GameDataChecksumKey";
static NSString* const GTGameDataCharactersKey = @"GameDataCharactersKey";
static NSString* const GTGameDataSelectedCharactersKey = @"GameDataSelectedCharactersKey";

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

#pragma mark - Local Storage

- (instancetype)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if (self) {
        _highScore = [decoder decodeDoubleForKey: GTGameDataHighScoreKey];
        _coins = [decoder decodeDoubleForKey: GTGameDataTotalCoinsKey];
        _selectedCharacterIndex = [decoder decodeIntegerForKey:GTGameDataCharacterKey];
        _purchasesCharacters = [decoder decodeObjectForKey:GTGameDataCharactersKey];
        _selectedCharacter = [decoder decodeObjectForKey:GTGameDataSelectedCharactersKey];
    }
    
    [self updateFromiCloud:nil];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeDouble:self.highScore forKey: GTGameDataHighScoreKey];
    [encoder encodeDouble:self.coins forKey: GTGameDataTotalCoinsKey];
    [encoder encodeInteger:self.selectedCharacterIndex forKey:GTGameDataCharacterKey];
    [encoder encodeObject:self.purchasesCharacters forKey:GTGameDataCharactersKey];
    [encoder encodeObject:self.selectedCharacter forKey:GTGameDataSelectedCharactersKey];
}

+ (instancetype)loadInstance{
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData: decodedData];
        
        NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier: GTGameDataChecksumKey];
        
        if ([checksumOfSavedFile isEqualToString: checksumInKeychain]) {
            GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
            return gameData;
        }
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
#pragma mark - iCloud

- (instancetype)init{
    self = [super init];
    if (self) {
        //1
        if([NSUbiquitousKeyValueStore defaultStore]) {
            //2
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateFromiCloud:)
                                                         name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)updateFromiCloud:(NSNotification*) notificationObject{
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    long cloudHighScore = [iCloudStore doubleForKey: GTGameDataHighScoreKey];
    self.highScore = MAX(cloudHighScore, self.highScore);
    
    long cloudCoins = [iCloudStore doubleForKey:GTGameDataTotalCoinsKey];
    self.coins = MAX(cloudCoins, self.coins);
    if ([iCloudStore objectForKey:GTGameDataCharactersKey]) {
        self.purchasesCharacters = [iCloudStore objectForKey:GTGameDataCharactersKey];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName: GTGameDataUpdatedFromiCloud object:nil];
}

-(void)updateiCloud{
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    long cloudHighScore = [iCloudStore doubleForKey: GTGameDataHighScoreKey];
    
    if (self.highScore > cloudHighScore) {
        [iCloudStore setDouble:self.highScore forKey: GTGameDataHighScoreKey];
    }

    [iCloudStore setDouble:self.coins forKey:GTGameDataTotalCoinsKey];
    
    [iCloudStore setObject:self.purchasesCharacters forKey:GTGameDataCharactersKey];
        [iCloudStore synchronize];
    
}

#pragma mark - Action Methods
- (void)reset{
    self.score = 0;
}

- (void)save{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
    
    //hash data with keychain
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    if ([KeychainWrapper keychainStringFromMatchingIdentifier: GTGameDataChecksumKey]) {
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:GTGameDataChecksumKey];
    } else {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:GTGameDataChecksumKey];
    }
    
    if([NSUbiquitousKeyValueStore defaultStore]) {
        [self updateiCloud];
    }

}

@end
