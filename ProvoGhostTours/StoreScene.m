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
@property (nonatomic, strong) NSArray *characterNamesArray;
@property (nonatomic, strong) NSArray *imageNamesArray;
@property (nonatomic, strong) NSMutableArray *coinAmounts;
@property (nonatomic, strong) UIButton *characterButton;
@property (nonatomic, strong) UIButton *purchaseWithCoinButton;
@property (nonatomic, strong) AGSpriteButton *button;
@property (nonatomic, assign) NSInteger characterIndex;
@property (nonatomic, strong) BWSegmentedControl *segmentedControl;
@property (nonatomic, strong) CFCoverFlowView *coverFlowView;

@end

@implementation StoreScene

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

    [self addSegmentedControl];
    [self addCoverView];
    
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back_Alpha"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 40;
    [self.view addSubview:backButton];
    
    self.characterNamesArray = @[@"Max", @"Derik", @"Ninja", @"Provo Mayor", @"Elf", @"Dinosaur", @"Retro"];
    self.coinAmounts = [NSMutableArray array];
    self.coinAmounts = @[@"0", @"0", @"100", @"150", @"200", @"300", @"400"].mutableCopy;
    
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
    
    self.purchaseWithCoinButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 75, CGRectGetMaxY(self.coverFlowView.frame) + 60, 150, 50)];
    [self.purchaseWithCoinButton setTitle:@"0 Coins" forState:UIControlStateNormal];
    [self.purchaseWithCoinButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.purchaseWithCoinButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [self.purchaseWithCoinButton setTintColor:[UIColor whiteColor]];
    self.purchaseWithCoinButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:18];
    [self.purchaseWithCoinButton addTarget:self action:@selector(purchaseWithCoinsSelected) forControlEvents:UIControlEventTouchUpInside];
    self.purchaseWithCoinButton.tag = 50;
    [self.view addSubview:self.purchaseWithCoinButton];

    if ([GameData sharedGameData].selectedCharacterIndex == 0) {
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
        self.purchaseWithCoinButton.hidden = YES;
    }else{
        [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
        self.purchaseWithCoinButton.hidden = NO;
    }
}

- (void)addSegmentedControl{
    UIImage *bike = [UIImage imageNamed:@"Biking"];
    UIImage *flashlight = [UIImage imageNamed:@"FlashLight"];
    self.segmentedControl = [BWSegmentedControl segmentedControlWithImages:@[bike, flashlight] titles:@[@"character", @"items"]];
    self.segmentedControl.topColor = [UIColor clearColor];
    self.segmentedControl.selectedItemIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentImageTintColor = [UIColor lightGrayColor];
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.frame = CGRectMake(100, 15, self.frame.size.width - 200, 60);
    self.segmentedControl.tag = 10;
    [self.view addSubview:self.segmentedControl];
    
}

- (void)addCoverView{
    self.imageNamesArray = @[@"Max_1", @"Derik_1", @"Ninja_1",@"Mayor_1", @"Elf_1", @"Dino_1", @"Retro_1"];
    
    self.coverFlowView = [[CFCoverFlowView alloc] initWithFrame:CGRectMake(100.0, 100.0, self.view.frame.size.width, 55.0)];
    self.coverFlowView.center = [self.view convertPoint:self.view.center fromScene:self];
    self.coverFlowView.delegate = self;
    self.coverFlowView.pageItemWidth = self.view.frame.size.width/2;
    self.coverFlowView.pageItemCoverWidth = 0.0;
    self.coverFlowView.pageItemHeight = 55.0;
    self.coverFlowView.pageItemCornerRadius = 5.0;
    [self.coverFlowView setPageItemsWithImageNames:self.imageNamesArray];
    self.coverFlowView.tag = 20;
    [self.view addSubview:self.coverFlowView];
    
    self.characterIndex = 0;
}

- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didScrollPageItemToIndex:(NSInteger)index{

    self.characterLabel.text = [self.characterNamesArray objectAtIndex:index];
    [self.purchaseWithCoinButton setTitle:[NSString stringWithFormat:@"%@ coins", [self.coinAmounts objectAtIndex:index]] forState:UIControlStateNormal];
    if ([[self.coinAmounts objectAtIndex:index] isEqualToString:@"0"]) {
        self.purchaseWithCoinButton.hidden = YES;
    }else{
        self.purchaseWithCoinButton.hidden = NO;
    }
    
    if ([GameData sharedGameData].selectedCharacterIndex == index) {
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
    }else{
        [self.characterButton setTitle:@"Select" forState:UIControlStateNormal];
    }

    self.characterIndex = index;
    
}

-(void)coverFlowView:(CFCoverFlowView *)coverFlowView didSelectPageItemAtIndex:(NSInteger)index{
    if (index == self.characterIndex) {
        [GameData sharedGameData].selectedCharacterIndex = index;
        [[GameData sharedGameData] save];
        [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
    }
}

- (void)characterSelected{
    if ([self.characterButton.titleLabel.text isEqualToString:@"Selected"]) {
        return;
    }
    [self.characterButton setTitle:@"Selected" forState:UIControlStateNormal];
    [GameData sharedGameData].selectedCharacterIndex = self.characterIndex;
    [[GameData sharedGameData] save];
       NSLog(@"Selected");
    
}

- (void)purchaseWithCoinsSelected{
    NSLog(@"coins selected");
}

- (void)segmentChanged:(id)sender{
    NSLog(@"segment changed");
}

- (void)backButtonPressed:(id)sender{
    GameScene *gameScene = [[GameScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition fadeWithDuration:.65];
    [self.view presentScene:gameScene transition:transition];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:20] removeFromSuperview];
    [[self.view viewWithTag:30] removeFromSuperview];
    [[self.view viewWithTag:40] removeFromSuperview];
    [[self.view viewWithTag:50] removeFromSuperview];
    [self.characterLabel removeFromParent];
    
}

@end
