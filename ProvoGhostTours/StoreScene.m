//
//  StoreScene.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/4/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "StoreScene.h"
#import "GameScene.h"
#import "CFCoverFlowView.h"
#import "GameData.h"
#import "AGSpriteButton.h"
#import "BWSegmentedControl.h"
#import "PGTIAPManager.h"
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger, CharacterIndex) {
    Maxxx,
    Derik,
    Ninja,
    Mayor,
    Elf,
    Dino,
    Retro
};


@interface StoreScene() <CFCoverFlowViewDelegate>

@property (nonatomic, strong) SKLabelNode *characterLabel;
@property (nonatomic, strong) NSMutableArray *characterNames;
@property (nonatomic, strong) NSMutableArray *characterNamesArray;
@property (nonatomic, strong) NSMutableArray *imageNamesArray;
@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, strong) NSMutableArray *coinAmounts;
@property (nonatomic, strong) UIButton *characterButton;
@property (nonatomic, strong) UIButton *purchaseWithCoinButton;
@property (nonatomic, strong) AGSpriteButton *button;
@property (nonatomic, assign) NSInteger characterIndex;
@property (nonatomic, strong) BWSegmentedControl *segmentedControl;
@property (nonatomic, strong) CFCoverFlowView *coverFlowView;
@property (nonatomic, strong) SKLabelNode *coinLabel;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) UIButton *restoreButton;
@end

@implementation StoreScene

static NSString* const CharacterCost = @"$0.99";

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        // 3
        self.backgroundColor = [SKColor blackColor];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"Sky2"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
    
    self.products = [NSMutableArray array];
    [self requestProducts];
    [self addCoverView];

    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back_Alpha"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 40;
    [self.view addSubview:backButton];
    
    self.characterNamesArray = [NSMutableArray array];
    for (NSDictionary *dict in [GameData sharedGameData].purchasesCharacters) {
        [self.characterNamesArray addObject:dict[@"title"]];
        
    }
    self.coinAmounts = [NSMutableArray array];
    self.coinAmounts = @[@"0", @"100", @"500", @"500", @"500", @"500", @"500"].mutableCopy;
    
    self.characterLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.characterLabel.text = [self.characterNamesArray objectAtIndex:0];
    self.characterLabel.fontSize = 32;
    self.characterLabel.zPosition = 2;
    self.characterLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.coverFlowView.frame) + 30);
    [self.characterLabel setScale:0.1];
    [self addChild:self.characterLabel];
    [self.characterLabel runAction:[SKAction scaleTo:1 duration:.5]];
    
    self.characterButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 75, CGRectGetMaxY(self.coverFlowView.frame) + 20, 150, 50)];
    [self.characterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.characterButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [self.characterButton setTintColor:[UIColor whiteColor]];
    self.characterButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:18];
    [self.characterButton addTarget:self action:@selector(characterSelected) forControlEvents:UIControlEventTouchUpInside];
    self.characterButton.tag = 30;
    [self.view addSubview:self.characterButton];
    
    self.restoreButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 75, self.view.frame.size.height - 30, 150, 21)];
    [self.restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.restoreButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [self.restoreButton setTintColor:[UIColor whiteColor]];
    self.restoreButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:10];
    [self.restoreButton addTarget:self action:@selector(restorePurchasesPressed) forControlEvents:UIControlEventTouchUpInside];
    self.restoreButton.tag = 80;
    [self.restoreButton setTitle:@"Restore Purchases" forState:UIControlStateNormal];
    [self.view addSubview:self.restoreButton];
    
    self.purchaseWithCoinButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 75, CGRectGetMaxY(self.coverFlowView.frame) + 60, 150, 50)];
    [self.purchaseWithCoinButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.purchaseWithCoinButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [self.purchaseWithCoinButton setTintColor:[UIColor whiteColor]];
    self.purchaseWithCoinButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:18];
    [self.purchaseWithCoinButton addTarget:self action:@selector(purchaseWithCoinsSelected) forControlEvents:UIControlEventTouchUpInside];
    self.purchaseWithCoinButton.tag = 50;
    [self.view addSubview:self.purchaseWithCoinButton];
    self.purchaseWithCoinButton.hidden = YES;
    
    self.coinLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.coinLabel.text = [NSString stringWithFormat:@"Coins: %ld", [GameData sharedGameData].coins];
    self.coinLabel.fontSize = [self convertFontSize:14];
    self.coinLabel.zPosition = 4;
    self.coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.coinLabel.position = CGPointMake(10, 10);
    self.coinLabel.fontColor = [UIColor yellowColor];
    [self addChild:self.coinLabel];


    if ([GameData sharedGameData].selectedCharacterIndex == 0) {
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
        
    }else{
        [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
    }
    
    self.characterNames = [NSMutableArray array];
    for (NSDictionary *dict in [GameData sharedGameData].purchasesCharacters) {
        [self.characterNames addObject:dict[@"name"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestored) name:IAPHelperProductRestoredNotification object:nil];
}

#pragma mark - Segmented Control
- (void)addSegmentedControl{
    UIImage *bike = [UIImage imageNamed:@"Biking"];
    UIImage *flashlight = [UIImage imageNamed:@"FlashLight"];
    self.segmentedControl = [BWSegmentedControl segmentedControlWithImages:@[bike, flashlight] titles:@[@"character", @"items"]];
    self.segmentedControl.topColor = [UIColor clearColor];
    self.segmentedControl.selectedItemIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentImageTintColor = [UIColor lightGrayColor];
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.frame = CGRectMake(100, 15, self.frame.size.width - 200, 60);
    self.segmentedControl.tag = 70;
    [self.view addSubview:self.segmentedControl];
    
}

- (void)segmentChanged:(id)sender{
    //    if (self.segmentedControl.selectedItemIndex == 0) {
    //        [self.coverFlowView setPageItemsWithImageNames:self.imageNamesArray];
    //    }else{
    //        [self.coverFlowView setPageItemsWithImageNames:self.itemsArray];
    //    }
    NSLog(@"segment changed");
}

#pragma mark - Cover Flow

- (void)addCoverView{
    self.imageNamesArray = [NSMutableArray array];
    for (NSDictionary *dict in [GameData sharedGameData].purchasesCharacters) {
        [self.imageNamesArray addObject:dict[@"name"]];
        
    }
    
//    self.imageNamesArray = @[@"Max_1", @"Derik_1", @"Ninja_1",@"Mayor_1", @"Elf_1", @"Dino_1", @"Retro_1"];
    self.itemsArray = @[@"Flashed", @"Flashlight"];
    
    self.coverFlowView = [[CFCoverFlowView alloc] initWithFrame:CGRectMake(100.0, 100.0, self.view.frame.size.width, 55.0)];
    self.coverFlowView.center = [self.view convertPoint:self.view.center fromScene:self];
    self.coverFlowView.delegate = self;
    self.coverFlowView.pageItemWidth = self.view.frame.size.width/2;
    self.coverFlowView.pageItemCoverWidth = 0.0;
    self.coverFlowView.pageItemHeight = 55.0;
    self.coverFlowView.pageItemCornerRadius = 5.0;
    
    if (self.segmentedControl.selectedItemIndex == 0) {
        [self.coverFlowView setPageItemsWithImageNames:self.imageNamesArray];
    }else{
        [self.coverFlowView setPageItemsWithImageNames:self.itemsArray];
    }
    
    self.coverFlowView.tag = 20;
    [self.view addSubview:self.coverFlowView];
    
    self.characterIndex = 0;
}

- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didScrollPageItemToIndex:(NSInteger)index{

    self.characterIndex = index;
    self.characterButton.hidden = NO;
    
    self.characterLabel.text = [self.characterNamesArray objectAtIndex:index];
    [self.purchaseWithCoinButton setTitle:[NSString stringWithFormat:@"%@ coins", [self.coinAmounts objectAtIndex:index]] forState:UIControlStateNormal];
    
    NSString *amountString = [self.coinAmounts objectAtIndex:index];
    int amount = [amountString intValue];
    
    //Check if enough coins
    if ([GameData sharedGameData].coins < amount) {
        [self.purchaseWithCoinButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:0 alpha:.6] forState:UIControlStateNormal];
        self.purchaseWithCoinButton.enabled = NO;
    }else{
        [self.purchaseWithCoinButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        self.purchaseWithCoinButton.enabled = YES;
    }
    
    //Check if character is current selected one
    if ([GameData sharedGameData].selectedCharacterIndex == index) {
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
    }else{
        [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
    }
    
    //Check if character has been purchased already
    NSDictionary *dict = [[GameData sharedGameData].purchasesCharacters objectAtIndex:index];
    if ([dict[@"purchased"] isEqualToString:@"N"]) {
        self.purchaseWithCoinButton.hidden = NO;
        
//        if (![dict[@"name"] isEqualToString:@"derik"]) {
        [self.characterButton setTitle:CharacterCost forState:UIControlStateNormal];
//        }else{
//            self.characterButton.hidden = YES;
//        }
    }else{
        self.purchaseWithCoinButton.hidden = YES;
    }
}

-(void)coverFlowView:(CFCoverFlowView *)coverFlowView didSelectPageItemAtIndex:(NSInteger)index{
    if (index == self.characterIndex) {
        [GameData sharedGameData].selectedCharacterIndex = index;
        [GameData sharedGameData].selectedCharacter = [self.imageNamesArray objectAtIndex:index];
        [[GameData sharedGameData] save];
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
    }
}

- (void)characterSelected{
    if ([self.characterButton.titleLabel.text isEqualToString:@"Selected"]) {
        return;
    }else if ([self.characterButton.titleLabel.text isEqualToString:CharacterCost]){
        [self purchaseCharacter];

    }else{
        
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
        [GameData sharedGameData].selectedCharacterIndex = self.characterIndex;
        [GameData sharedGameData].selectedCharacter = [self.imageNamesArray objectAtIndex:self.characterIndex];
        NSLog(@"%@", [GameData sharedGameData].selectedCharacter);
        [[GameData sharedGameData] save];
 
    }
}

#pragma mark - Purchasing

- (void)purchaseCharacter{
    
    NSString *character = [self.characterNames objectAtIndex:self.characterIndex];
    SKProduct *pro = [SKProduct new];
    
    for (SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:[NSString stringWithFormat:@"com.derikflanary.ProvoGhostTours.%@", character]]) {
            pro = product;
        }
    }
    [[PGTIAPManager sharedInstance] buyProduct:pro];
}

- (void)requestProducts{
    
    [[PGTIAPManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        self.products = products.mutableCopy;

//        NSLog(@"products: %@", products);
    }];
}

- (void)productPurchased:(NSNotification *)notification{
    NSDictionary *identifierDictionary = [notification userInfo];
    NSString *identifier = identifierDictionary[@"productIdentifier"];
    
    [self savePurchase:identifier];
    
    [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
    self.purchaseWithCoinButton.hidden = YES;
}

- (void)productRestored{
    
}

- (void)purchaseWithCoinsSelected{
    //update purchased characters
    [self savePurchase:nil];
    
    //update coins
    NSString *amountString = [self.coinAmounts objectAtIndex:self.characterIndex];
    int amount = [amountString intValue];
    [GameData sharedGameData].coins = [GameData sharedGameData].coins - amount;
    self.coinLabel.text = [NSString stringWithFormat:@"Coins: %ld", [GameData sharedGameData].coins];
    
    //save purchase
    [[GameData sharedGameData] save];
    
    [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
    self.purchaseWithCoinButton.hidden = YES;
}

- (void)savePurchase:(NSString *)identifier{
    
    if (!identifier) {
        NSMutableArray *mutableCharactersPurchased = [GameData sharedGameData].purchasesCharacters.mutableCopy;
        NSDictionary *dict = [[GameData sharedGameData].purchasesCharacters objectAtIndex:self.characterIndex];
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        [newDict addEntriesFromDictionary:dict];
        [newDict setObject:@"Y" forKey:@"purchased"];
        [mutableCharactersPurchased replaceObjectAtIndex:self.characterIndex withObject:newDict];
        [GameData sharedGameData].purchasesCharacters = mutableCharactersPurchased;

    }else{
        NSArray *componentArray = [identifier componentsSeparatedByString:@"."];
        NSString *character = [componentArray lastObject];
        NSUInteger index = [self.characterNames indexOfObject:character];
        NSDictionary *dict = [[GameData sharedGameData].purchasesCharacters objectAtIndex:index];
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        [newDict addEntriesFromDictionary:dict];
        [newDict setObject:@"Y" forKey:@"purchased"];
        NSMutableArray *mutableCharactersPurchased = [GameData sharedGameData].purchasesCharacters.mutableCopy;
        [mutableCharactersPurchased replaceObjectAtIndex:index withObject:newDict];
        [GameData sharedGameData].purchasesCharacters = mutableCharactersPurchased;
    }
    
    [[GameData sharedGameData] save];
}

- (void)restorePurchasesPressed{
    [[PGTIAPManager sharedInstance] restoreCompletedTransactions];
}

#pragma mark - Other Methods

- (void)backButtonPressed:(id)sender{
    GameScene *gameScene = [[GameScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition fadeWithDuration:.65];
    [self.view presentScene:gameScene transition:transition];
    [[self.view viewWithTag:20] removeFromSuperview];
    [[self.view viewWithTag:30] removeFromSuperview];
    [[self.view viewWithTag:40] removeFromSuperview];
    [[self.view viewWithTag:50] removeFromSuperview];
    [[self.view viewWithTag:70] removeFromSuperview];
    [[self.view viewWithTag:80] removeFromSuperview];
    [self.characterLabel removeFromParent];
    
}

- (float)convertFontSize:(float)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
