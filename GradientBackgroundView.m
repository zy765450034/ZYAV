//
//  GradientBackgroundView.m
//  ZYAV
//
//  Created by wu weiwei on 2017/4/11.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//
#import "UIColor+Hex.h"
#import "GradientBackgroundView.h"

@implementation GradientBackgroundView

- (nullable instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self gradientLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self gradientLayer];
    }
    return self;
}

- (void)gradientLayer{

    CGPoint startPoint =  CGPointMake(-0.2, 0);
    CGPoint endPoint =  CGPointMake(1.2, 1);
    self.gradient = [CAGradientLayer layer];
    self.gradient.shadowOffset = CGSizeMake(20, 20);
    self.gradient.startPoint = startPoint;
    self.gradient.endPoint = endPoint;
    NSArray* gradients =  @[(__bridge id)[NSColor colorWithHex:0xC43B31 alpha:0.8].CGColor,(__bridge id)[NSColor colorWithHex:0x96368D alpha:0.8].CGColor,(__bridge id)[NSColor colorWithHex:0x135EA4 alpha:0.8].CGColor];
    self.gradient.colors = gradients;
    [self setLayer:self.gradient];
    

}

@end
