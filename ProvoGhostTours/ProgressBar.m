//
//  ProgressBar.m
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/18/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

#import "ProgressBar.h"

@interface ProgressBar()

@property (nonatomic, strong) SKSpriteNode *backgroundSpriteNode;
@property (nonatomic, strong) SKCropNode *fillCropNode;
@property (nonatomic, strong) SKSpriteNode *fillSpriteNode;
@property (nonatomic, strong) SKSpriteNode *overlaySpriteNode;

@property (nonatomic, strong) SKTexture *backgroundTexture;
@property (nonatomic, strong) SKTexture *fillTexture;
@property (nonatomic, strong) SKTexture *overlayTexture;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) SKLabelNode *titleLabelNode;;

@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;


@end

@implementation ProgressBar
- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress)
    {
        _progress = MIN(MAX(progress, 0.0), 1.0);
        
        [self progressDidChange];
    }
    
//    CGFloat hue = MAX(0, ((120.0 * progress) / 360.0) - (20.0/360.0));
//    self.fillColor = [UIColor colorWithHue:hue saturation:0.9 brightness:0.9 alpha:1.0];
}

#pragma mark - Init / Dealloc

- (instancetype)init
{
    return [self initWithSize:CGSizeZero
              backgroundColor:nil
                    fillColor:nil
                  borderColor:nil
                  borderWidth:0.0
                 cornerRadius:0.0];
}

- (instancetype)initWithSize:(CGSize)size
             backgroundColor:(UIColor *)backgroundColor
                   fillColor:(UIColor *)fillColor
                 borderColor:(UIColor *)borderColor
                 borderWidth:(CGFloat)borderWidth
                cornerRadius:(CGFloat)cornerRadius
{
    NSParameterAssert(backgroundColor);
    NSParameterAssert(fillColor);
    NSParameterAssert(borderColor);
    
    self = [super init];
    
    if (self)
    {
        _size = size;
        _backgroundColor = backgroundColor;
        _fillColor = fillColor;
        _borderColor = borderColor;
        _cornerRadius = cornerRadius;
        _borderWidth = borderWidth;
        
        [self progressBarNodeCommonInit];
    }
    
    return self;
}

- (instancetype)initWithBackgroundTexture:(SKTexture *)backgroundTexture
                              fillTexture:(SKTexture *)fillTexture
                           overlayTexture:(SKTexture *)overlayTexture
{
    NSParameterAssert(backgroundTexture);
    NSParameterAssert(fillTexture);
    NSParameterAssert(overlayTexture);
    
    self = [super init];
    
    if (self)
    {
        _backgroundTexture = backgroundTexture;
        _fillTexture = fillTexture;
        _overlayTexture = overlayTexture;
        
        [self progressBarNodeCommonInit];
    }
    
    return self;
}

#pragma mark - Initialization

- (void)progressBarNodeCommonInit
{
    _progress = 0.0;
    
    [self initializeBackgroundSpriteNode];
    [self initializeFillCropNode];
    [self initializeFillSpriteNode];
    [self initializeOverlaySpriteNode];
    [self initializeTitleLabelNode];
    [self progressDidChange];
}

- (void)initializeBackgroundSpriteNode
{
    /* If a custom background texture wasn't provided, we generate a custom texture from
     CAShapeLayer (because SKShapeNode sucks) */
    if (!_backgroundTexture)
    {
        [self initializeBackgroundTexture];
    }
    
    _backgroundSpriteNode = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture];
    
    [self addChild:_backgroundSpriteNode];
}

- (void)initializeBackgroundTexture
{
    CAShapeLayer *backgroundLayer = [self newShapeLayerFromBoundsPath];
    
    backgroundLayer.lineWidth = 0.0f;
    backgroundLayer.fillColor = _backgroundColor.CGColor;
    
    _backgroundTexture = [self textureFromLayer:backgroundLayer];
}

/* The fill crop node uses the same texture as the background sprite to mask the fill sprite,
 effectively masking it to the outline of the bar background. */
- (void)initializeFillCropNode
{
    _fillCropNode = [SKCropNode new];
    
    // mask to background texture
    _fillCropNode.maskNode = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture];
    
    [self addChild:_fillCropNode];
}

/* The fill sprite node is sandwiched between the background sprite node and the overlay sprite node,
 and it is masked to the background texture by the fill crop node */
- (void)initializeFillSpriteNode
{
    if (_fillTexture)
    {
        _fillSpriteNode = [SKSpriteNode spriteNodeWithTexture:_fillTexture];
    }
    else
    {
        _fillSpriteNode = [SKSpriteNode spriteNodeWithColor:_fillColor size:_size];
    }
    
    _fillSpriteNode.anchorPoint = CGPointMake(0.0f, 0.5f);
    _fillSpriteNode.position = CGPointMake(-round(_size.width / 2.0), 0.0);
    
    [_fillCropNode addChild:_fillSpriteNode];
}

/* The overlay sprite node sits on top of the fill and background sprite nodes, giving the proper appearance
 of a bar being filled on the inside */
- (void)initializeOverlaySpriteNode
{
    /* If a custom overlay texture wasn't provided, we generate a custom texture from
     CAShapeLayer (because SKShapeNode sucks) */
    if (!_overlayTexture)
    {
        [self initializeOverlayTexture];
    }
    
    _overlaySpriteNode = [SKSpriteNode spriteNodeWithTexture:_overlayTexture];
    
    [self addChild:_overlaySpriteNode];
}

- (void)initializeOverlayTexture
{
    CAShapeLayer *shapeLayer = [self newShapeLayerFromBoundsPath];
    
    shapeLayer.strokeColor = _borderColor.CGColor;
    shapeLayer.lineWidth = _borderWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    _overlayTexture = [self textureFromLayer:shapeLayer];
}

- (void)initializeTitleLabelNode
{
    _titleLabelNode = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
    
    _titleLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _titleLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _titleLabelNode.fontColor = [UIColor whiteColor];
    _titleLabelNode.fontSize = 12.0f;
    
    [self addChild:_titleLabelNode];
}

#pragma mark - Utility

- (CAShapeLayer *)newShapeLayerFromBoundsPath
{
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    CGFloat halfBorderWidth = round(_borderWidth / 2.0);
    
    shapeLayer.frame = CGRectMake(0.0, 0.0, _size.width, _size.height);
    
    /* Inset the path so that we don't stroke outside of our bounds */
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(shapeLayer.bounds, halfBorderWidth, halfBorderWidth) cornerRadius:_cornerRadius].CGPath;
    
    return shapeLayer;
}

/* We are going from CALayer -> UIImage -> SKTexture here, so that we can create SKSpriteNodes instead of SKShapeNodes (SKShapeNode doesn't work well with SKCropNode),
 which are then plugged into the maskNode property of a SKCropNode.  This approach also conveniently allows us to use the same code path for custom textures and generated
 textures if you just want a basic progress bar */
- (SKTexture *)textureFromLayer:(CALayer *)layer
{
    CGFloat width = layer.frame.size.width;
    CGFloat height = layer.frame.size.height;
    
    // value of 0 for scale will use device's main screen scale
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, width, height));
    
    [layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    SKTexture *texture = [SKTexture textureWithImage:image];
    
    return texture;
}

#pragma mark - Interface Updates

- (void)progressDidChange
{
    CGFloat halfBorderWidth = (_borderWidth / 2.0);
    
    CGFloat fillWidth = self.size.width - self.borderWidth;
    CGFloat fillHeight = self.size.height - self.borderWidth;
    CGFloat height = (fillHeight * _progress);
    CGFloat width = halfBorderWidth + fillWidth;
    
    _fillSpriteNode.size = CGSizeMake(width, height);
}

@end
