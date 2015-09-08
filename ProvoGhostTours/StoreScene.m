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

typedef NS_ENUM(NSInteger, CharacterIndex) {
    Main,
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

    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back_Alpha"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 10;
    [self.view addSubview:backButton];
    
    self.characterNamesArray = @[@"Main", @"Max", @"Derik", @"Ninja", @"Provo Mayor", @"Elf", @"Dinosaur", @"Retro"];
    
    self.characterLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.characterLabel.text = [self.characterNamesArray objectAtIndex:0];
    self.characterLabel.fontSize = 24;
    self.characterLabel.zPosition = 2;
    self.characterLabel.position = CGPointMake(CGRectGetMidX(self.frame),80);
    [self.characterLabel setScale:0.1];
    [self addChild:self.characterLabel];
    [self.characterLabel runAction:[SKAction scaleTo:1 duration:.5]];
   
    [self addCoverView];

}

- (void)backButtonPressed:(id)sender{
    GameScene *gameScene = [[GameScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition doorsCloseVerticalWithDuration:.35];
    [self.view presentScene:gameScene transition:transition];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:20] removeFromSuperview];
    [self.characterLabel removeFromParent];
    
}

- (void)addCoverView{
    CFCoverFlowView *coverFlowView = [[CFCoverFlowView alloc] initWithFrame:CGRectMake(100.0, 100.0, self.view.frame.size.width, 200.0)];
    coverFlowView.center = [self.view convertPoint:self.view.center fromScene:self];
    coverFlowView.delegate = self;
    coverFlowView.pageItemWidth = self.view.frame.size.width/2;
    coverFlowView.pageItemCoverWidth = 0.0;
    coverFlowView.pageItemHeight = 55.0;
    coverFlowView.pageItemCornerRadius = 5.0;
    [coverFlowView setPageItemsWithImageNames:@[@"Character1",@"Max_1", @"Derik_1", @"Ninja_1",@"Mayor", @"Elf_1", @"Dino_1", @"Biker1_a"]];
    coverFlowView.tag = 20;
    [self.view addSubview:coverFlowView];
    
}

- (void)coverFlowView:(CFCoverFlowView *)coverFlowView didScrollPageItemToIndex:(NSInteger)index{

    self.characterLabel.text = [self.characterNamesArray objectAtIndex:index];

    
}

@end
