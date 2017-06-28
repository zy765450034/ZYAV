//
//  appSingle.h
//  ZYAV
//
//  Created by wu weiwei on 2017/5/11.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSingle : NSObject

+ (nullable AppSingle *)sharedInstance;

-(void)setPath:( NSString*)path;

-( NSString*)path;

-(void)setVideoFormat:(NSString*)str;

-(NSString*)videoFormat;

-(void)setAudioFormat:(NSString*)str;

-(NSString*)audioFormat;

@end
