//
//  SPDraggingProxyView.m
//  DragNDropFeature
//
//  Created by Nevyn Bengtsson on 2012-12-14.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "DragonProxyView.h"
#import <QuartzCore/QuartzCore.h>

@interface DragonProxyView ()
{
    UIView *_iconContainer;
    UIView *_icon;
    UIImageView *_actionIcon;
    
    UIView *_titleContainer;
    UILabel *_titleLabel;
}

@end

@implementation DragonProxyView
- (id)initWithIcon:(UIImage*)icon title:(NSString*)title subtitle:(NSString*)subtitle
{
    if(!(self = [super initWithFrame:(CGRect){.size=icon.size}]))
        return nil;
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
    CGSize iconSize = CGSizeMake(80, 80);
    CGSize labelSize = [title sizeWithAttributes:@{
		NSFontAttributeName: titleFont
	}];
    static const CGFloat iconCornerRadius = 10.;
    static const CGFloat labelCornerRadius = 5.;
    static const CGFloat margin = 12;
    static const CGFloat textContainerYMargin = 2;
    static const CGFloat textContainerXMargin = 4;
    
    _icon = [[UIImageView alloc] initWithImage:icon];
    _icon.frame = (CGRect){.size=iconSize};
    _icon.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _icon.layer.cornerRadius = iconCornerRadius;
    _icon.layer.masksToBounds = YES;

    _iconContainer = [[UIView alloc] initWithFrame:(CGRect){.size=iconSize}];
    _iconContainer.layer.cornerRadius = iconCornerRadius;
    _iconContainer.layer.borderColor = [UIColor colorWithWhite:0 alpha:.4].CGColor;
    _iconContainer.layer.shadowOpacity = .5;
    _iconContainer.layer.shadowOffset = CGSizeMake(0, 3);
    [_iconContainer addSubview:_icon];
    [self addSubview:_iconContainer];
    
    _titleContainer = [[UIView alloc] initWithFrame:CGRectMake(iconSize.width + margin, iconSize.height/2. - labelSize.height/2. - textContainerYMargin, labelSize.width + textContainerXMargin*2, labelSize.height + textContainerYMargin*2)];
    _titleContainer.layer.shadowOpacity = .5;
    _titleContainer.layer.shadowOffset = CGSizeMake(0, 3);
    _titleContainer.layer.cornerRadius = labelCornerRadius;
    _titleContainer.backgroundColor = [UIColor colorWithRed:0.268 green:0.314 blue:0.792 alpha:1.000];
    
    _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){.size=labelSize, .origin = {textContainerXMargin,textContainerYMargin}}];
    _titleLabel.text = title;
    _titleLabel.font = titleFont;
    _titleLabel.textColor = [UIColor colorWithRed:0.946 green:0.951 blue:0.946 alpha:1.000];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_titleContainer addSubview:_titleLabel];
    [self addSubview:_titleContainer];
    
    _actionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dragndrop-add"]];
    _actionIcon.frame = CGRectMake(70, 10, 20, 20);
    _actionIcon.layer.shadowOpacity = .5;
    _actionIcon.layer.shadowOffset = CGSizeMake(0, 3);
    [self addSubview:_actionIcon];
    
    self.frame = CGRectMake(0, 0, CGRectGetMaxX(_titleContainer.bounds), CGRectGetMaxY(_iconContainer.bounds));
    
    self.layer.anchorPoint = CGPointMake(45./CGRectGetMaxX(self.frame), 0.8);
    
    return self;
}

- (void)animateOut:(dispatch_block_t)completion forSuccess:(BOOL)wasSuccessful
{
	if(wasSuccessful) {
		if(completion) completion();
	} else {
		[UIView animateWithDuration:.5 animations:^{
			self.alpha = 0;
		} completion:(id)completion];
	}
}
@end

@implementation DragonScreenshotProxyView
- (instancetype)initWithScreenshot:(UIImage *)screenshot
{
	if(!(self = [super initWithImage:screenshot]))
		return nil;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowOpacity = .8;
	self.layer.shadowRadius = 30;
	
	return self;
}
- (void)animateOut:(dispatch_block_t)completion forSuccess:(BOOL)wasSuccessful
{
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
	animation.fromValue = @(self.layer.shadowRadius);
	animation.toValue = @0;

	self.layer.shadowRadius = 0;
	[self.layer addAnimation:animation forKey:@"shadowRadius"];
	[CATransaction commit];
}
@end

@implementation DragonNotProxyView
- (instancetype)initWithView:(UIView *)screenshot
{
    if(!(self = [super initWithFrame:screenshot.bounds]))
        return nil;
    
    // Our view is that of the cell's controller view.
    self.workedOnView = [screenshot viewWithTag:12345];
    if (!self.workedOnView) {
        // Can assume we're using DashBoard.
    }
    
    [self addSubview:self.workedOnView];
    self.workedOnView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH*TOP_CELL_MULTIPLIER, SCREEN_HEIGHT*TOP_CELL_MULTIPLIER);
    
    return self;
}

- (void)animateOut:(dispatch_block_t)completion forSuccess:(BOOL)wasSuccessful {}

- (void)handleAutoResizingAtPoint:(CGPoint)p {
    // Handle auto-resizing of xen view as we move between collection views.
    CGFloat transform = 1.0;
    
    CGFloat topCollectionY = SCREEN_HEIGHT*0.35;
    CGFloat bottomCollectionY = SCREEN_HEIGHT*0.65;
    
    CGFloat highTransform = self.workedOnView.bounds.size.width / SCREEN_WIDTH*TOP_CELL_MULTIPLIER;
    CGFloat lowTransform = self.workedOnView.bounds.size.width / SCREEN_WIDTH*BOTTOM_CELL_MULTIPLIER;
    
    XENlog(@"High trans: %f, low trans: %f, topY: %f, bottomY: %f, originY: %f", highTransform, lowTransform, topCollectionY, bottomCollectionY, self.center.y);
    
    if (self.center.y > topCollectionY && self.center.y < bottomCollectionY) {
        // Normalise originY between the two known points
        CGFloat normalised = self.center.y - topCollectionY;
        bottomCollectionY -= topCollectionY;
        
        CGFloat percentage = 1.0 - normalised/bottomCollectionY;
        
        XENlog(@"Percentage is %f", percentage);
        
        transform = lowTransform + (highTransform - lowTransform)*percentage;
        
        if (p.x == 0 && p.y == 0) {
            transform = (self.center.y < SCREEN_HEIGHT*0.6 ? highTransform : lowTransform);
        }
    } else if (self.center.y > bottomCollectionY) {
        transform = lowTransform;
    } else if (self.center.y < topCollectionY) {
        transform = highTransform;
    }
    
    XENlog(@"Transform: %f", transform);
    
    self.workedOnView.transform = CGAffineTransformMakeScale(transform, transform);
    self.workedOnView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    //[self viewWithTag:12345].frame = CGRectMake([self viewWithTag:12345].frame.origin.x, [self viewWithTag:12345].frame.origin.y, [self viewWithTag:12345].frame.size.width, [self viewWithTag:12345].frame.size.height);
}

@end
