//
//  ProgressBar.h
//  ProvoGhostTours
//
//  Created by Derik Flanary on 9/18/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ProgressBar : SKNode

/** Current progress of the progress bar, value between 0.0 and 1.0 */
@property (nonatomic) CGFloat progress;

/** Configurable title label, displayed centered in the progress bar by default */
@property (nonatomic, strong, readonly) SKLabelNode *titleLabelNode;

/** Initialize a plain progress bar with the given colors and sizes. */
- (instancetype)initWithSize:(CGSize)size
             backgroundColor:(UIColor *)backgroundColor
                   fillColor:(UIColor *)fillColor
                 borderColor:(UIColor *)borderColor
                 borderWidth:(CGFloat)borderWidth
                cornerRadius:(CGFloat)cornerRadius;

/** Initialize a custom progress bar with the given textures for background, fill and overlay layers */
- (instancetype)initWithBackgroundTexture:(SKTexture *)backgroundTexture
                              fillTexture:(SKTexture *)fillTexture
                           overlayTexture:(SKTexture *)overlayTexture;


@end



