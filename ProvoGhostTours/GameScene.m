//
//  GameScene.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 8/12/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

#import "GameScene.h"
#import "Ghost.h"
#import <AVFoundation/AVFoundation.h>
#import <MPCoachMarks/MPCoachMarks.h>
#import <GameKit/GameKit.h>
#import "StoreScene.h"
#import "GameData.h"

@interface GameScene() <SKPhysicsContactDelegate, MPCoachMarksViewDelegate, GKGameCenterControllerDelegate>

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) SKSpriteNode *biker;
@property (nonatomic) SKSpriteNode *movingBackground;
@property (nonatomic) SKSpriteNode *backWheel;
@property (nonatomic) SKSpriteNode *frontWheel;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastTreeSpawnInterval;
@property (nonatomic) SKSpriteNode *light;
@property (nonatomic) SKSpriteNode *superLight;
@property (nonatomic) SKNode *centerPoint;
@property (nonatomic, strong) NSMutableArray *ghostArray;
@property (nonatomic, strong) NSMutableArray *contactedGhostArray;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) SKLabelNode *coinLabel;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKAction *ghostSound;
@property (strong, nonatomic) SKAction *bikerAnimation;
@property (nonatomic, assign) int minDuration;
@property (nonatomic, assign) int maxDuration;
@property (nonatomic, assign) BOOL gameover;
@property (nonatomic, assign) BOOL gameStart;
@property (nonatomic, assign) BOOL firstPlay;
@property (nonatomic) SKLabelNode *highscoreLabel;
@property (nonatomic) SKLabelNode *titleLabel;
@property (nonatomic) SKSpriteNode *tree;
@property (nonatomic) SKSpriteNode *detector;
@property (nonatomic) NSTimeInterval delta;
@property (nonatomic, assign) BOOL gameCenterEnabled;
@property (nonatomic, strong) NSString *leaderboardIdentifier;
@property (nonatomic, assign) BOOL gamePaused;
@property (nonatomic, assign) NSTimeInterval theCurrentTime;
@property (nonatomic, strong) NSMutableArray *characterImageArray;
@property (nonatomic, strong) NSMutableArray *characterAnimationArray;
@property (nonatomic, strong) NSMutableArray *ghostImageArray;
@property (nonatomic, assign) NSUInteger selectedInt;

@end

@implementation GameScene

static const uint32_t flashlightCategory     =  0x1 << 0;
static const uint32_t ghostCategory        =  0x1 << 1;
static const uint32_t bikerCategory         = 0x1 << 2;

- (id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor blackColor];
        self.gameStart = NO;
        
        [self addMainSprites];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdateGameData:)
                                                     name:GTGameDataUpdatedFromiCloud
                                                   object:nil];
        //create Physics for collisions
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //Add Bike Sound Effect
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"bikePedal" withExtension:@"caf"];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = -1;
        self.audioPlayer.volume = 0.7;
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"SoundDisabled"]) {
            self.audioPlayer.volume = 0.7;
            self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
        }else{
            self.audioPlayer.volume = 0.0;
            self.ghostSound = nil;
        }

        [self.audioPlayer play];
        self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
        
        [self authenticateLocalPlayer];
        
        
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTGameDataUpdatedFromiCloud object:nil];
}

#pragma mark - Start Screen

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

    
    [self addStartScreenButtons];
}

- (void)addStartScreenButtons{
    
    self.titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.titleLabel.text = @"Provo Ghost Tours";
    self.titleLabel.fontSize = 36;
    self.titleLabel.zPosition = 4;
    self.titleLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 85);
    
    [self.titleLabel setScale:0.1];
    [self addChild:self.titleLabel];
    [self.titleLabel runAction:[SKAction scaleTo:1.0 duration:0.5]];

    UIButton *startGameButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMidY(self.frame) + 20, self.frame.size.width, 50)];
    [startGameButton setTitle:@"Play" forState:UIControlStateNormal];
    [startGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startGameButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [startGameButton setTintColor:[UIColor whiteColor]];
    startGameButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:32];
    [startGameButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    startGameButton.tag = 200;
    [self.view addSubview:startGameButton];
    
    UIButton *rateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(startGameButton.frame) + 40, self.frame.size.width, 50)];
    [rateButton setTitle:@"Rate" forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [rateButton setTintColor:[UIColor whiteColor]];
    rateButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:14];
    [rateButton addTarget:self action:@selector(rateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    rateButton.tag = 100;
    [self.view addSubview:rateButton];
    
    UIButton *muteButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, 25, 25, 25)];
    [muteButton setImage:[UIImage imageNamed:@"Mute"] forState:UIControlStateNormal];
    [muteButton setImage:[UIImage imageNamed:@"MuteFilled"] forState:UIControlStateSelected];
    [muteButton addTarget:self action:@selector(mutePressed:) forControlEvents:UIControlEventTouchUpInside];
    muteButton.tag = 300;
    [self.view addSubview:muteButton];
    
    UIButton *leaderButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [leaderButton setImage:[UIImage imageNamed:@"Leaderboard"] forState:UIControlStateNormal];
    [leaderButton setImage:[UIImage imageNamed:@"Leaderboard_alpha"] forState:UIControlStateSelected];
    [leaderButton addTarget:self action:@selector(leaderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    leaderButton.tag = 400;
    [self.view addSubview:leaderButton];
    
    UIButton *shopButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 12.5, 25, 25, 25)];
    shopButton.center = [self.view convertPoint:self.view.center fromScene:self];
    [shopButton setImage:[UIImage imageNamed:@"shop_icon"] forState:UIControlStateNormal];
    [shopButton setImage:[UIImage imageNamed:@"shop_icon_alpha"] forState:UIControlStateSelected];
    [shopButton addTarget:self action:@selector(shopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    shopButton.tag = 500;
    [self.view addSubview:shopButton];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]) {
        [GameData sharedGameData].highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"highScore"];
    }
    
    self.highscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.highscoreLabel.text = [NSString stringWithFormat:@"High Score: %lu", [GameData sharedGameData].highScore];
    self.highscoreLabel.fontSize = 14;
    self.highscoreLabel.zPosition = 4;
    self.highscoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.titleLabel.position.y - 40);
    [self.highscoreLabel setScale:0.1];
    [self addChild:self.highscoreLabel];
    [self.highscoreLabel runAction:[SKAction scaleTo:1 duration:.5]];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"SoundDisabled"]) {
        muteButton.selected = NO;
        NSLog(@"sound on");
    }else{
        muteButton.selected = YES;
        NSLog(@"sound off");
    }
}

#pragma mark - Main Scene Setup

- (void)addMainSprites{
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"Sky2"];
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:background];
    
    self.movingBackground = [SKSpriteNode spriteNodeWithImageNamed:@"All Buildings"];
    self.movingBackground.size = CGSizeMake(2562, self.frame.size.height);
    self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    self.movingBackground.anchorPoint = CGPointZero;
    self.movingBackground.zPosition = 1;
    [self addChild:self.movingBackground];
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"BikeFrame"];
    self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height - 15);
    self.player.zPosition = 2;
    [self addChild:self.player];
    
    self.backWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.backWheel.position = CGPointMake(self.player.position.x - 22, self.player.position.y - 10);
    self.backWheel.zPosition = 2;
    [self addChild:self.backWheel];
    
    self.frontWheel = [SKSpriteNode spriteNodeWithImageNamed:@"Bike1_tire_a"];
    self.frontWheel.position = CGPointMake(self.player.position.x + 22, self.player.position.y - 10);
    self.frontWheel.zPosition = 2;
    [self addChild:self.frontWheel];
    
    if (![GameData sharedGameData].selectedCharacterIndex) {
        [GameData sharedGameData].selectedCharacterIndex = 0;
    }
    
    [self setUpArrays];
    
    
    self.biker = [SKSpriteNode spriteNodeWithImageNamed:[self.characterImageArray objectAtIndex:self.selectedInt]];
    self.biker.position = CGPointMake(self.player.position.x - 2, self.player.position.y + self.biker.size.height / 3);
    self.biker.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.biker.size];
    self.biker.physicsBody.categoryBitMask = bikerCategory;
    self.biker.physicsBody.contactTestBitMask = ghostCategory;
    self.biker.physicsBody.collisionBitMask = 0;
    self.biker.zPosition = 2;
    [self addChild:self.biker];
    
    self.bikerAnimation = [self animationFromPlist:[self.characterAnimationArray objectAtIndex:self.selectedInt]];
    
    [self rotateWheels];
    [self.biker runAction:self.bikerAnimation withKey:@"biker"];
    [self addTreeAtX:self.frame.size.width - 100];
}

- (void)setUpArrays{
    self.characterImageArray = [NSMutableArray array];
    self.characterAnimationArray = [NSMutableArray array];
    self.ghostImageArray = [NSMutableArray array];
    for (NSDictionary *dict in [GameData sharedGameData].purchasesCharacters) {
        [self.characterImageArray addObject:dict[@"name"]];
        [self.characterAnimationArray addObject:[NSString stringWithFormat:@"%@Animation", dict[@"name"]]];
        [self.ghostImageArray addObject:dict[@"ghost"]];
    }
    self.selectedInt = [self.characterImageArray indexOfObject:[GameData sharedGameData].selectedCharacter];
}
- (void)startGame{
    
    if (!self.firstPlay) {
        [self addMainSprites];
        [self.audioPlayer play];
        
        //create Physics for collisions
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        }
    
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"MPCoachMarksShown"];
    if (!coachMarksShown) {
        // Don't show again
        [self showCoachMarks];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MPCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        self.gameStart = YES;
    }

    self.firstPlay = NO;
    
    [self addFlashlight];
//    [self addSuperLight];
    [self addInGameObjects];
    
    //Set up arrays for ghost spawning and deleting
    self.ghostArray = [NSMutableArray array];
    self.contactedGhostArray = [NSMutableArray array];
    
    self.minDuration = 8;
    self.maxDuration = 10;
    if (coachMarksShown) {
        [self addGhost];
    }
    
}

- (void)addInGameObjects{
    
    float margin = 10;

    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.scoreLabel.text = @"Score: 0";
    self.scoreLabel.fontSize = [self convertFontSize:14];
    self.scoreLabel.zPosition = 4;
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.scoreLabel.position = CGPointMake(margin, margin);
    [self addChild:self.scoreLabel];
    
    self.coinLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.coinLabel.text = [NSString stringWithFormat:@"Coins: %ld", [GameData sharedGameData].coins];
    self.coinLabel.fontColor = [UIColor yellowColor];
    self.coinLabel.fontSize = [self convertFontSize:14];
    self.coinLabel.zPosition = 4;
    self.coinLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.coinLabel.position = CGPointMake(self.scoreLabel.position.x, self.scoreLabel.position.y + margin * 2);
    [self addChild:self.coinLabel];
    
    UIButton *flashButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width -50, self.frame.size.height - 50, 25, 25)];
    [flashButton setImage:[UIImage imageNamed:@"Flashed"] forState:UIControlStateNormal];
    [flashButton setImage:[UIImage imageNamed:@"Flashbang"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(flashPressed:) forControlEvents:UIControlEventTouchUpInside];
    flashButton.tag = 10;
    [self.view addSubview:flashButton];
    
}

- (void)addFlashlight{
    
    //add the flashlight
    self.centerPoint = [SKNode new];
    self.centerPoint.position = CGPointMake(self.player.position.x, self.player.position.y + 20);
    if (!self.gameStart) {
        [self addChild:self.centerPoint];
    }
    
    self.light = [SKSpriteNode spriteNodeWithImageNamed:@"LampLight"];
    self.light.alpha = 0.35;
    self.light.position = CGPointMake(0, self.light.size.height/2);
    [self.centerPoint addChild:self.light];
    self.light.zPosition = 2;
    
    //create a physics body for the light's shape
    CGFloat offsetX = self.light.frame.size.width/2;
    CGFloat offsetY = self.light.frame.size.height/2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (([[UIScreen mainScreen] scale] == 2.0)) {
        CGPathMoveToPoint(path, NULL, 154 - offsetX, 325 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 324 - offsetY);
        CGPathAddLineToPoint(path, NULL, 59 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 98 - offsetX, 1 - offsetY);
        CGPathCloseSubpath(path);
    }else if (([[UIScreen mainScreen] scale] == 3.0)){
        CGPathMoveToPoint(path, NULL, 231 - offsetX, 415 - offsetY);
        CGPathAddLineToPoint(path, NULL, -1 - offsetX, 413 - offsetY);
        CGPathAddLineToPoint(path, NULL, 83 - offsetX, -1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 145 - offsetX, 3 - offsetY);
    }else{
        CGPathMoveToPoint(path, NULL, 76 - offsetX, 168 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 167 - offsetY);
        CGPathAddLineToPoint(path, NULL, 31 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 50 - offsetX, 0 - offsetY);
    }
    
    self.light.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    self.light.physicsBody.dynamic = YES;
    self.light.physicsBody.categoryBitMask = flashlightCategory;
    self.light.physicsBody.contactTestBitMask = ghostCategory;
    self.light.physicsBody.collisionBitMask = 0;
    self.light.physicsBody.usesPreciseCollisionDetection = YES;
}

- (void)addSuperLight{
    
    //add the flashlight
    
    self.superLight = [SKSpriteNode spriteNodeWithImageNamed:@"superlight.png"];
    self.superLight.alpha = .8;
    self.superLight.position = CGPointMake(0, self.superLight.size.height/2);
    [self.centerPoint addChild:self.superLight];
    self.light.zPosition = 2;
    
    CGFloat offsetX = self.superLight.frame.size.width/2;
    CGFloat offsetY = self.superLight.frame.size.height/2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (([[UIScreen mainScreen] scale] == 2.0)) {
        CGPathMoveToPoint(path, NULL, 294 - offsetX, 368 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 368 - offsetY);
        CGPathAddLineToPoint(path, NULL, 140 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 174 - offsetX, 0 - offsetY);
        CGPathCloseSubpath(path);
    }else if (([[UIScreen mainScreen] scale] == 3.0)){
        CGPathMoveToPoint(path, NULL, 441 - offsetX, 552 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 552 - offsetY);
        CGPathAddLineToPoint(path, NULL, 210 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 261 - offsetX, 0 - offsetY);
        CGPathCloseSubpath(path);
    }else{
        CGPathMoveToPoint(path, NULL, 147 - offsetX, 184 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 184 - offsetY);
        CGPathAddLineToPoint(path, NULL, 70 - offsetX, 1 - offsetY);
        CGPathAddLineToPoint(path, NULL, 87 - offsetX, 0 - offsetY);
        CGPathCloseSubpath(path);
    }

    
    
    CGPathCloseSubpath(path);
    
    self.superLight.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    self.superLight.physicsBody.dynamic = YES;
    self.superLight.physicsBody.categoryBitMask = flashlightCategory;
    self.superLight.physicsBody.contactTestBitMask = ghostCategory;
    self.superLight.physicsBody.collisionBitMask = 0;
    self.superLight.physicsBody.usesPreciseCollisionDetection = YES;
}

#pragma mark - Start Screen Button Methods

- (void)playButtonPressed:(id)sender{
    self.firstPlay = YES;
    [self startGame];
    [[self.view viewWithTag:200] removeFromSuperview];
    [[self.view viewWithTag:100] removeFromSuperview];
    [[self.view viewWithTag:300] removeFromSuperview];
    [[self.view viewWithTag:400] removeFromSuperview];
    [[self.view viewWithTag:500] removeFromSuperview];
    [self.highscoreLabel removeFromParent];
    [self.titleLabel removeFromParent];
}

- (void)rateButtonPressed:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1031990080"]];
    NSLog(@"rate pressed");
}

- (void)shopButtonPressed:(id)sender{
    NSLog(@"shop pressed");
    StoreScene *storeScene = [[StoreScene alloc]initWithSize:self.size];
    SKTransition *transition = [SKTransition fadeWithDuration:.65];
    [self.view presentScene:storeScene transition:transition];
    [[self.view viewWithTag:200] removeFromSuperview];
    [[self.view viewWithTag:100] removeFromSuperview];
    [[self.view viewWithTag:300] removeFromSuperview];
    [[self.view viewWithTag:400] removeFromSuperview];
    [[self.view viewWithTag:500] removeFromSuperview];
    [[self.view viewWithTag:321] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
}

#pragma mark - Ghost Methods

- (void)addGhost{
    
    //Determine where to spawn ghost along X axis
    int minX = -100;
    int maxX = self.frame.size.width + 100;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    Ghost *ghost = [Ghost spriteNodeWithTexture:[SKTexture textureWithImageNamed:[self.ghostImageArray objectAtIndex:self.selectedInt]]];
    [self.ghostArray addObject:ghost];
    //create sprite
    if (actualX > self.frame.size.width/2) {
        ghost.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@_right", [self.ghostImageArray objectAtIndex:self.selectedInt]]];
    }
    
    //Determine a random Y if the spawn's X is off screen
    int minY = 50;
    int maxY = self.frame.size.height + 10;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the ghost slightly off-screen along the top edge,
    // and along a random position along the X axis as calculated above
    if (actualX < 0 || actualX > self.frame.size.width) {
        ghost.position = CGPointMake(actualX, actualY);
    }else{
        ghost.position = CGPointMake(actualX, self.frame.size.height + ghost.size.height/2);
    }
    
    ghost.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ghost.size];
    ghost.physicsBody.dynamic = YES;
    ghost.physicsBody.categoryBitMask = ghostCategory;
    ghost.physicsBody.contactTestBitMask = flashlightCategory;
    ghost.physicsBody.contactTestBitMask = bikerCategory;
    ghost.physicsBody.collisionBitMask = 0;
    ghost.zPosition = 2;
    ghost.alpha = 0.0;
    
    [self addChild:ghost];
    
    // Determine speed of the ghost
    int rangeDuration = self.maxDuration - self.minDuration;
    int actualDuration = (arc4random() % rangeDuration) + self.minDuration;
    
    // Create the actions
    SKAction *actionMove = [SKAction moveTo:self.biker.position duration:actualDuration];
    [ghost runAction:actionMove];

}

- (void)updateGhostInLight:(NSTimeInterval)delta{
    //Update the ghost if it is in the light
    if (self.gameover) {
        return;
    }
    
    NSMutableArray *removedGhostsArray = [NSMutableArray array];
    for (Ghost *ghost in self.contactedGhostArray) {
        if (ghost.alpha >= .9) {
            
            //update score
            [GameData sharedGameData].score += 10;
            [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %ld", [GameData sharedGameData].score]];
            
            
            
            //kill ghost
            [self.ghostArray removeObject:ghost];
            [removedGhostsArray addObject:ghost];
            
            [ghost die];
            [self runAction:self.ghostSound];
            
            int randomInt = (arc4random() % 10) + 1;
            if (randomInt > 4) {
                //update coins
                SKSpriteNode *coin = [SKSpriteNode spriteNodeWithImageNamed:@"coin"];
                coin.position = ghost.position;
                coin.zPosition = 2;
                [self addChild:coin];
                
                SKAction *die = [SKAction fadeOutWithDuration:1];
                SKAction *remove = [SKAction removeFromParent];
                [coin runAction:[SKAction sequence:@[die, remove]]];
                
                [GameData sharedGameData].coins += 1;
                [self.coinLabel setText:[NSString stringWithFormat:@"Coins: %ld", [GameData sharedGameData].coins]];
            }
            
        }else{
            [ghost collidedWithFlashlight:delta];
        }
    }
    //remove dead ghosts
    [self.contactedGhostArray removeObjectsInArray:removedGhostsArray];
}

- (void)addTutorialGhost{
    
    Ghost *ghost = [Ghost spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Ghost1"]];
    [self.ghostArray addObject:ghost];
    //create sprite
    ghost.texture = [SKTexture textureWithImageNamed:@"Ghost1_right"];
    ghost.position = CGPointMake(CGRectGetMidX(self.frame) + 10, self.frame.size.height);
    ghost.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ghost.size];
    ghost.physicsBody.dynamic = YES;
    ghost.physicsBody.categoryBitMask = ghostCategory;
    ghost.physicsBody.contactTestBitMask = flashlightCategory;
    ghost.physicsBody.contactTestBitMask = bikerCategory;
    ghost.physicsBody.collisionBitMask = 0;
    ghost.zPosition = 2;
    ghost.alpha = 0.0;
    
    [self addChild:ghost];
    
    // Create the actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), 100) duration:3];
    [ghost runAction:actionMove];
}

#pragma mark - Tree Methods

- (void)addTreeAtX:(CGFloat)X{
    
    int minZ = 0;
    int maxZ = 4;
    int rangeZ = maxZ - minZ;
    int actualZ = (arc4random() % rangeZ) + minZ;
    if (actualZ == 2 || 0) {
        self.tree = [SKSpriteNode spriteNodeWithImageNamed:@"Tree3"];
    }else{
        self.tree = [SKSpriteNode spriteNodeWithImageNamed:@"Tree4"];
    }
    if (actualZ == 0) {
        self.tree.position = CGPointMake(X, 0);
    }else{
        self.tree.position = CGPointMake(X, -7);
    }
    
    self.tree.anchorPoint = CGPointZero;
    self.tree.zPosition = actualZ;
    [self addChild:self.tree];
}

#pragma mark - Flash Bang
- (void)flashPressed:(UIButton*)sender{
    [self flashAnimation];
}

- (void)flashAnimation{
    SKSpriteNode *flashBackground = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:self.size];
    [self addChild:flashBackground];
    flashBackground.anchorPoint = CGPointZero;
    flashBackground.zPosition = 10;
    SKAction *flash = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1 duration:.25];
    SKAction *showGhosts = [SKAction performSelector:@selector(makeEveryGhostVisable) onTarget:self];
    SKAction *unflash = [SKAction colorizeWithColor:[UIColor clearColor] colorBlendFactor:1 duration:.25];
    [flashBackground runAction:[SKAction sequence:@[flash, showGhosts, unflash]]];

}

- (void)makeEveryGhostVisable{
    for (Ghost *ghost in self.ghostArray) {
        ghost.alpha = .89;
    }
}

#pragma mark - Detector Methods

- (CGFloat)SDistanceBetweenPoints:(CGPoint)first andSecond:(CGPoint)second{
    return hypotf(second.x - first.x, second.y - first.y);
}

#pragma mark Update Methods
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    if (self.gameover) {
        return;
    }
    
    if (!self.gameStart) {
        return;
    }
    
    //Set time between spawns and speeds
    int minSpawn = 2.0;
    int maxSpawn = 5.0;

    if ([GameData sharedGameData].score < 100) {
        minSpawn = 5;
        maxSpawn = 10;
        self.minDuration = 9;
        self.maxDuration = 13;
    }else if ([GameData sharedGameData].score < 200){
        minSpawn = 4;
        maxSpawn = 9;
        self.minDuration = 8;
        self.maxDuration = 12;
    }else if ([GameData sharedGameData].score < 300){
        minSpawn = 3;
        maxSpawn = 7;
        self.minDuration = 8;
        self.maxDuration = 11;
    }else if ([GameData sharedGameData].score < 400){
        minSpawn = 3;
        maxSpawn = 6;
        self.minDuration = 8;
        self.maxDuration = 10;
    }else{
        minSpawn = 3;
        maxSpawn = 5;
        self.minDuration = 7;
        self.maxDuration = 10;
    }
    
    int rangeSpawn = maxSpawn - minSpawn;
    int actualSpawn = (arc4random() % rangeSpawn) + minSpawn;
    
    //spawn new ghost if time between spawns has happended
    self.lastSpawnTimeInterval += timeSinceLast;
    
    if (self.lastSpawnTimeInterval > actualSpawn) {
        self.lastSpawnTimeInterval = 0;
        [self addGhost];
    }
    
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.gameover) {
        return;
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;

    self.theCurrentTime = currentTime;

    //Move the background
    if (self.movingBackground.position.x <= - 2600) {
        self.movingBackground.position = CGPointMake(self.frame.size.width, 0);
    }else{
        self.movingBackground.position = CGPointMake(self.movingBackground.position.x - .75, self.movingBackground.position.y);
    }
    
    //Move the trees
    if (self.tree.position.x <= -175) {
        [self.tree removeFromParent];
        int actualSpawn = (arc4random() % 200) + 10;
        [self addTreeAtX:self.view.frame.size.width + actualSpawn];
    }else{
        self.tree.position = CGPointMake(self.tree.position.x - .75, self.tree.position.y);
    }

    // Handle time delta.
    
    if (timeSinceLast > .02) {
        self.lastUpdateTimeInterval = currentTime;
        if ([self.contactedGhostArray count] > 0) {
            [self updateGhostInLight:timeSinceLast];
        }
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

#pragma mark - Animations
- (void)rotateWheels{
    //create repeating rotation for wheels
    SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 4.0];
    SKAction *repeat = [SKAction repeatActionForever:oneRevolution];
    [self.backWheel runAction:repeat withKey:@"backWheel"];
    [self.frontWheel runAction:repeat withKey:@"frontWheel"];
}

- (SKAction *)animationFromPlist:(NSString *)animPlist{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:animPlist ofType:@"plist"];
    NSArray *animImages = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString *imageName in animImages) {
        [animFrames addObject:[SKTexture textureWithImageNamed:imageName]];
    }
    
    float framesOverOneSecond = 1.0f/4.0f;
    
    return [SKAction repeatActionForever:[SKAction animateWithTextures:animFrames timePerFrame:framesOverOneSecond resize:NO restore:YES]]; // 6
    
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (self.gameover) {
        return;
    }
    if (!self.gameStart) {
        return;
    }
    if (![self.children containsObject:self.centerPoint]) {
        [self addChild:self.centerPoint];
    }
    
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = atan2f(dY, dX) + 1.571f;
        [self.centerPoint runAction:[SKAction rotateToAngle:angle duration:0.0 shortestUnitArc:YES]];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.gameover) {
        return;
    }
    if (!self.gameStart) {
        return;
    }
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        float dY = self.centerPoint.position.y - location.y;
        float dX = self.centerPoint.position.x - location.x;
        float angle = (atan2f(dY, dX)) + 1.571f;
        self.centerPoint.zRotation = angle;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.gameover) {
        return;
    }
    if (!self.gameStart) {
        return;
    }
    [self.centerPoint removeFromParent];
    
    for (Ghost *ghost in self.contactedGhostArray) {
        ghost.isContacted = NO;
    }
    [self.contactedGhostArray removeAllObjects];

}

#pragma mark collision methods

- (void)didBeginContact:(SKPhysicsContact *)contact{
    if (self.gameover) {
        return;
    }
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    
    if ((firstBody.categoryBitMask & flashlightCategory) != 0 &&
        (secondBody.categoryBitMask & ghostCategory) != 0)
    {
        if ([secondBody.node isKindOfClass:[Ghost class]]) {
                [self flashlight:(SKSpriteNode *)firstBody.node didCollideWithGhost:(Ghost *)secondBody.node];
        }
    }
    if ((firstBody.categoryBitMask & ghostCategory) != 0 &&
        (secondBody.categoryBitMask & bikerCategory) != 0)
    {
        Ghost *ghost = (Ghost *)firstBody.node;
        ghost.alpha = .8;
        [self ghostCollidesWithBiker];
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact{
    if (self.gameover) {
        return;
    }
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & flashlightCategory) != 0 &&
        (secondBody.categoryBitMask & ghostCategory) != 0){
        
        if ([secondBody.node isKindOfClass:[Ghost class]]) {
            [self flashlight:(SKSpriteNode *)firstBody.node didStopCollidingWithGhost:(Ghost *)secondBody.node];
        }
       
    }
}

- (void)flashlight:(SKSpriteNode *)flashlight didCollideWithGhost:(Ghost *)ghost {
    [ghost initialCollisionWithLight];
    
    ghost.isContacted = YES;
    [self.contactedGhostArray addObject:ghost];
}

- (void)flashlight:(SKSpriteNode *)flashlight didStopCollidingWithGhost:(Ghost *)ghost{
    
    ghost.isContacted = NO;
    [self.contactedGhostArray removeObject:ghost];
}


#pragma mark - Game Over

- (void)ghostCollidesWithBiker{
    [[self.view viewWithTag:50] removeFromSuperview];
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOverLabel.text = @"Game Over!";
    gameOverLabel.fontSize = 48;
    gameOverLabel.zPosition = 4;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame));
    
    [gameOverLabel setScale:0.1];
    [self addChild:gameOverLabel];
    [gameOverLabel runAction:[SKAction scaleTo:1.0 duration:0.5]];
    
    UIButton *restartButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMidY(self.frame) + 20, self.frame.size.width, 50)];
    [restartButton setTitle:@"Play Again" forState:UIControlStateNormal];
    [restartButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [restartButton setTintColor:[UIColor whiteColor]];
    restartButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:14];
    [restartButton addTarget:self action:@selector(restartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    restartButton.tag = 321;
    [self.view addSubview:restartButton];
    

    if ([GameData sharedGameData].score > [GameData sharedGameData].highScore) {
        [GameData sharedGameData].highScore = [GameData sharedGameData].score;
    }
    [[GameData sharedGameData]save];
    
    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    highScoreLabel.text = [NSString stringWithFormat:@"High Score: %lu", [GameData sharedGameData].highScore];
    highScoreLabel.fontSize = 20;
    highScoreLabel.zPosition = 4;
    highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), gameOverLabel.position.y + 50);
    [highScoreLabel setScale:0.1];
    [self addChild:highScoreLabel];
    [highScoreLabel runAction:[SKAction scaleTo:1 duration:.5]];
    
    UIButton *rateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(restartButton.frame) + 40, self.frame.size.width, 50)];
    [rateButton setTitle:@"Rate" forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor colorWithWhite:1 alpha:.4] forState:UIControlStateHighlighted];
    [rateButton setTintColor:[UIColor whiteColor]];
    rateButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:14];
    [rateButton addTarget:self action:@selector(rateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    rateButton.tag = 100;
    [self.view addSubview:rateButton];

    UIButton *muteButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, 25, 25, 25)];
    [muteButton setImage:[UIImage imageNamed:@"Mute"] forState:UIControlStateNormal];
    [muteButton setImage:[UIImage imageNamed:@"MuteFilled"] forState:UIControlStateSelected];
    [muteButton addTarget:self action:@selector(mutePressed:) forControlEvents:UIControlEventTouchUpInside];
    muteButton.tag = 300;
    [self.view addSubview:muteButton];
    
    UIButton *shopButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - 25, 25, 25, 25)];
    [shopButton setImage:[UIImage imageNamed:@"shop_icon"] forState:UIControlStateNormal];
    [shopButton setImage:[UIImage imageNamed:@"shop_icon_alpha"] forState:UIControlStateSelected];
    [shopButton addTarget:self action:@selector(shopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    shopButton.tag = 500;
    [self.view addSubview:shopButton];
    
    UIButton *leaderButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 25, 25, 25)];
    [leaderButton setImage:[UIImage imageNamed:@"Leaderboard"] forState:UIControlStateNormal];
    [leaderButton setImage:[UIImage imageNamed:@"Leaderboard_alpha"] forState:UIControlStateSelected];
    [leaderButton addTarget:self action:@selector(leaderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    leaderButton.tag = 400;
    [self.view addSubview:leaderButton];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"SoundDisabled"]) {
        self.audioPlayer.volume = 0.7;
        self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
        muteButton.selected = NO;
        NSLog(@"sound on");
    }else{
        self.audioPlayer.volume = 0.0;
        self.ghostSound = nil;
        muteButton.selected = YES;
        NSLog(@"sound off");
    }
    [self.frontWheel removeActionForKey:@"frontWheel"];
    [self.backWheel removeActionForKey:@"backWheel"];
    [self.biker removeActionForKey:@"biker"];
    [self.audioPlayer stop];
    
    self.gameover = YES;
    
    [self reportScore:[GameData sharedGameData].score];

}

- (void) restartButtonPressed:(id)sender{
    [self removeAllChildren];
    [self removeAllActions];
    self.gameover = NO;
    [[self.view viewWithTag:321] removeFromSuperview];
    [[self.view viewWithTag:100] removeFromSuperview];
    [[self.view viewWithTag:300] removeFromSuperview];
    [[self.view viewWithTag:400] removeFromSuperview];
    [[self.view viewWithTag:500] removeFromSuperview];
    [[GameData sharedGameData]reset];
    [self startGame];
}

- (void)leaderButtonPressed:(id)sender{
    if (self.gameCenterEnabled) {
        [self showLeaderboardAndAchievements:YES];
    }
}

- (float)convertFontSize:(float)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}

- (void)mutePressed:(UIButton*)sender{
   
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"SoundDisabled"]) {
        sender.highlighted = NO;
        sender.selected = NO;
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"SoundDisabled"];
        self.audioPlayer.volume = 0.7;
        self.ghostSound = [SKAction playSoundFileNamed:@"ghostSound.caf" waitForCompletion:NO];
        NSLog(@"sound on");
    }else{
        sender.highlighted = YES;
        sender.selected = YES;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"SoundDisabled"];
        self.audioPlayer.volume = 0.0;
        self.ghostSound = nil;
        NSLog(@"sound off");
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Game Center

- (void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self.gameViewController presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                self.gameCenterEnabled = YES;
                NSLog(@"gamecenter enabled");
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        self.leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                self.gameCenterEnabled = NO;
            }
        }
    };
}

- (void)reportScore:(NSInteger)score{
    
    if (self.gameCenterEnabled) {
        GKScore *theScore = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        theScore.value = score;
        
        [GKScore reportScores:@[theScore] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    if (self.gameCenterEnabled) {
        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
        
        gcViewController.gameCenterDelegate = self;
        
        if (shouldShowLeaderboard) {
            gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
            gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
        }
        else{
            gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
        }
        
        [self.gameViewController presentViewController:gcViewController animated:YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Coach Marks
- (void)showCoachMarks{
    
    CGRect coachmark1 = CGRectMake(([UIScreen mainScreen].bounds.size.width - 125) / 2, 20, 125, 125);
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"Touch screen to activate flashlight and find ghosts",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                @"showArrow":[NSNumber numberWithBool:YES]
                                },
                            @{  @"rect": [NSValue valueWithCGRect:coachmark1],
                                @"caption": @"Hold the light on a ghost to defeat it",
                                @"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                @"position":[NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                                @"alignment":[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT]
                                }];
    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    [self.view addSubview:coachMarksView];
    coachMarksView.enableContinueLabel = NO;
    coachMarksView.enableSkipButton = NO;
    coachMarksView.maskColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    coachMarksView.delegate = self;
    [coachMarksView start];
    
}

- (void)coachMarksViewDidCleanup:(MPCoachMarks *)coachMarksView{
    self.gameStart = YES;
    [self.centerPoint removeFromParent];
}

- (void)coachMarksView:(MPCoachMarks *)coachMarksView willNavigateToIndex:(NSUInteger)index{
    if (index == 1) {
        [self addTutorialGhost];
    }
}

#pragma mark - Cloud Updating
- (void)didUpdateGameData:(NSNotification*)n{
    self.highscoreLabel.text = [NSString stringWithFormat:@"High: %li", [GameData sharedGameData].highScore];
}




@end
