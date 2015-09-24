//
//  AppDelegate.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "AppDelegate.h"
#import "GameData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]) {
        [GameData sharedGameData].highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"highScore"];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    
    if (!previousVersion) {
        // first launch
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
        
        [GameData sharedGameData].purchasesCharacters = @[@{@"name": @"max", @"purchased": @"Y", @"title": @"Max", @"ghost":@"Ghost1", @"ability": @"", @"cost": @"0"},
                                                          @{@"name": @"derik", @"purchased": @"N", @"title": @"Derik", @"ghost": @"Ghost1", @"ability": @"Less batteries needed to charge flashlight", @"cost": @"200"},
                                                          @{@"name": @"courtney", @"purchased": @"N", @"title": @"Courtney", @"ghost": @"Ghost1", @"ability": @"Use a wider flashlight", @"cost": @"300"},
                                                          @{@"name": @"mayor", @"purchased": @"N", @"title": @"Provo Mayor", @"ghost": @"Ghost_mayor", @"ability": @"Double your coin intake",@"cost": @"300"},
                                                          @{@"name": @"ninja", @"purchased": @"N", @"title": @"Ninja", @"ghost": @"Ghost_ninja", @"ability": @"Use a flashbomb on the ghosts", @"cost": @"500"},
                                                          @{@"name": @"dinosaur", @"purchased": @"N", @"title": @"Dinosaur", @"ghost": @"Ghost_dino", @"ability": @"Ghosts move slower", @"cost": @"500"},
                                                          @{@"name": @"elf", @"purchased": @"N", @"title": @"Elf", @"ghost": @"Ghost_elf", @"ability": @"Create a temporary barrier", @"cost": @"1000"},
                                                          @{@"name": @"retro", @"purchased": @"N", @"title": @"Retro", @"ghost": @"Ghost2", @"ability": @"", @"cost": @"100"}];
        
        [GameData sharedGameData].selectedCharacterIndex = 0;
        [GameData sharedGameData].selectedCharacter = @"max";
        [GameData sharedGameData].coins = 0;
        [GameData sharedGameData].allCharactersPurchased = 0;
        [[GameData sharedGameData] save];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MPCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NewLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    } else if ([previousVersion isEqualToString:currentAppVersion]) {
        // same version
    } else {
        // other version
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
        NSLog(@"updated");
        [GameData sharedGameData].purchasesCharacters = @[@{@"name": @"max", @"purchased": @"Y", @"title": @"Max", @"ghost":@"Ghost1", @"ability": @"", @"cost": @"0"},
                                                          @{@"name": @"derik", @"purchased": @"N", @"title": @"Derik", @"ghost": @"Ghost1", @"ability": @"Less batteries needed to charge flashlight", @"cost": @"200"},
                                                          @{@"name": @"courtney", @"purchased": @"N", @"title": @"Courtney", @"ghost": @"Ghost1", @"ability": @"Use a wider flashlight", @"cost": @"300"},
                                                          @{@"name": @"mayor", @"purchased": @"N", @"title": @"Provo Mayor", @"ghost": @"Ghost_mayor", @"ability": @"Double your coin intake",@"cost": @"300"},
                                                          @{@"name": @"ninja", @"purchased": @"N", @"title": @"Ninja", @"ghost": @"Ghost_ninja", @"ability": @"Use a flashbomb on the ghosts", @"cost": @"500"},
                                                          @{@"name": @"dinosaur", @"purchased": @"N", @"title": @"Dinosaur", @"ghost": @"Ghost_dino", @"ability": @"Ghosts move slower", @"cost": @"500"},
                                                          @{@"name": @"elf", @"purchased": @"N", @"title": @"Elf", @"ghost": @"Ghost_elf", @"ability": @"Create a temporary barrier", @"cost": @"1000"},
                                                          @{@"name": @"retro", @"purchased": @"N", @"title": @"Retro", @"ghost": @"Ghost2", @"ability": @"", @"cost": @"100"}];

        [GameData sharedGameData].selectedCharacterIndex = 0;
        [GameData sharedGameData].selectedCharacter = @"max";
        [GameData sharedGameData].coins = 0;
        [GameData sharedGameData].allCharactersPurchased = 0;
        [[GameData sharedGameData] save];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MPCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NewLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
