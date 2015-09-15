//
//  HashedIAPManager.m
//  Hashed
//
//  Created by Derik Flanary on 8/26/15.
//  Copyright (c) 2015 WI. All rights reserved.
//

#import "PGTIAPManager.h"

@implementation PGTIAPManager

+ (PGTIAPManager *)sharedInstance {
    static dispatch_once_t once;
    static PGTIAPManager * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.patter.hashed.upgradetopro",
                                      @"com.patter.hashed.trial",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
