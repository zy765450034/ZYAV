//
//  PlayEngineDelegate.h
//  ZYAV
//
//  Created by wu weiwei on 2017/6/16.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayEngineDelegate <NSObject>

-(void)show_window_size:(int)width height:(int)height;

-(void)update_rgb_image_display:(CGImageRef)imageRef;

-(void)update_cur_time:(int64_t)cur_time;

-(void)video_metadata_duration:(int64_t)duration;

@end
