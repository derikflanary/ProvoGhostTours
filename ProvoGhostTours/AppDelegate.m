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
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
            }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    
    if (!previousVersion) {
        // first launch
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
        
        [GameData sharedGameData].purchasesCharacters = @[@{@"name": @"max", @"purchased": @"Y", @"title": @"Max", @"ghost":@"Ghost1", @"ability": @""},
                                                          @{@"name": @"derik", @"purchased": @"Y", @"title": @"Derik", @"ghost": @"Ghost1", @"ability": @"Less batteries needed to charge flashlight"},
                                                          @{@"name": @"courtney", @"purchased": @"Y", @"title": @"Courtney", @"ghost": @"Ghost1", @"ability": @"Use a wider flashlight"},
                                                          @{@"name": @"ninja", @"purchased": @"Y", @"title": @"Ninja", @"ghost": @"Ghost_ninja", @"ability": @"Use a flashbomb on the ghosts"},
                                                          @{@"name": @"mayor", @"purchased": @"Y", @"title": @"Provo Mayor", @"ghost": @"Ghost_mayor", @"ability": @"Double your coin intake"},
                                                          @{@"name": @"elf", @"purchased": @"Y", @"title": @"Elf", @"ghost": @"Ghost_elf", @"ability": @"Create a temporary barrier"},
                                                          @{@"name": @"dinosaur", @"purchased": @"Y", @"title": @"Dinosaur", @"ghost": @"Ghost_dino", @"ability": @"None"},
                                                          @{@"name": @"retro", @"purchased": @"Y", @"title": @"Retro", @"ghost": @"Ghost2", @"ability": @"None"}];

        [GameData sharedGameData].selectedCharacterIndex = 0;
        [GameData sharedGameData].selectedCharacter = @"max";
        [GameData sharedGameData].coins = 0;
        [[GameData sharedGameData] save];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MPCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    } else if ([previousVersion isEqualToString:currentAppVersion]) {
        // same version
    } else {
        // other version
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
        NSLog(@"updated");
        [GameData sharedGameData].purchasesCharacters = @[@{@"name": @"max", @"purchased": @"Y", @"title": @"Max", @"ghost":@"Ghost1", @"ability": @"None"},
                                                          @{@"name": @"derik", @"purchased": @"Y", @"title": @"Derik", @"ghost": @"Ghost1", @"ability": @"Less batteries needed to charge flashlight"},
                                                          @{@"name": @"courtney", @"purchased": @"Y", @"title": @"Courtney", @"ghost": @"Ghost1", @"ability": @"Use a wider flashlight"},
                                                          @{@"name": @"ninja", @"purchased": @"Y", @"title": @"Ninja", @"ghost": @"Ghost_ninja", @"ability": @"Use a flashbomb on the ghosts"},
                                                          @{@"name": @"mayor", @"purchased": @"Y", @"title": @"Provo Mayor", @"ghost": @"Ghost_mayor", @"ability": @"Double your coin intake"},
                                                          @{@"name": @"elf", @"purchased": @"Y", @"title": @"Elf", @"ghost": @"Ghost_elf", @"ability": @"Create a temporary barrier"},
                                                          @{@"name": @"dinosaur", @"purchased": @"Y", @"title": @"Dinosaur", @"ghost": @"Ghost_dino", @"ability": @"None"},
                                                          @{@"name": @"retro", @"purchased": @"Y", @"title": @"Retro", @"ghost": @"Ghost2", @"ability": @"None"}];

        [GameData sharedGameData].selectedCharacterIndex = 0;
        [GameData sharedGameData].selectedCharacter = @"max";
        [GameData sharedGameData].coins = 0;
        [[GameData sharedGameData] save];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MPCoachMarksShown"];
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
