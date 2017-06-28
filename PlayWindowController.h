//
//  PlayWindowController.h
//  ZYAV
//
//  Created by wu weiwei on 2017/5/6.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlayWindowController : NSWindowController

-(instancetype)initPlayWindowWithPath:(NSString *)Path;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName size:(NSSize)size;

-(void)playPath:(NSString*)path;

- (void)updateRgbImageDisplay:(CGImageRef)imageRef;

- (void)updateCurTime:(int64_t)curTime;

-(void)update_video_duration:(int64_t)duration;

@end
