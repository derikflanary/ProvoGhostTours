//
//  IAPManager.h
//  Hashed
//
//  Created by Derik Flanary on 8/26/15.
//  Copyright (c) 2015 WI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRestoredNotification ;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPManager : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
