//
//  playerDelegate.h
//  ZYAV
//
//  Created by wu weiwei on 2017/5/5.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <libavcodec/avcodec.h>
@protocol PlayerDelegate <NSObject>

-(void)upload_frame:(NSBitmapImageRep* )bitmapImageRep;
-(void)upload_image:(NSImage* )image;
-(void)upload_picture:(AVPicture*)picture;
@end
