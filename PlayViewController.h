//
//  PlayViewController.h
//  ZYAV
//
//  Created by wu weiwei on 2017/5/4.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PlayViewController : NSViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil size:(NSSize)size;

- (void)updateRgbImage:(CGImageRef)imageRef;

- (void)updateCurTime:(int64_t)curTime;

-(void)update_duration:(int64_t)duration;

@end
