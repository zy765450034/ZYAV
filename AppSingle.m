//
//  appSingle.m
//  ZYAV
//
//  Created by wu weiwei on 2017/5/11.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import "AppSingle.h"

@implementation AppSingle{
    NSString* video_path;
    NSString* video_format;
    NSString* audio_format;
}

+ (nullable AppSingle *)sharedInstance{
    static AppSingle *_sharedInstanced = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstanced = [[AppSingle alloc] init];
        
        
    });
    return _sharedInstanced;
}
-(id)init{
    
    self = [super init];
    
    return self;
}

-(void)setPath:(NSString*)path{
    video_path = path;
    
}

-(NSString*)path{
    return video_path;
}

-(void)setVideoFormat:(NSString*)str{
    video_format = str;
}

-(NSString*)videoFormat{
    
    return video_format;
}
-(void)setAudioFormat:(NSString*)str{
    audio_format = str;
}

-(NSString*)audioFormat{
    return audio_format;
}
@end
