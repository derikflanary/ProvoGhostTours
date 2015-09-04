//
//  StoreScene.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/4/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "StoreScene.h"
#import "GameScene.h"

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
    //Add Bike Sound Effect
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back_Alpha"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 10;
    [self.view addSubview:backButton];

}


- (void)backButtonPressed:(id)sender{
    GameScene *gameScene = [[GameScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition doorsCloseVerticalWithDuration:.35];
    [self.view presentScene:gameScene transition:transition];
    [[self.view viewWithTag:10] removeFromSuperview];
    
}

@end
