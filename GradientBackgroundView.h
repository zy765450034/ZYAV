//
//  GradientBackgroundView.h
//  ZYAV
//
//  Created by wu weiwei on 2017/4/11.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>
@interface GradientBackgroundView : NSView
@property(nonatomic,strong) CAGradientLayer *gradient;
@end
