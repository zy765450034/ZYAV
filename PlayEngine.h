//
//  PlayEngine.h
//  ZYAV
//
//  Created by wu weiwei on 2017/6/15.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayEngineDelegate.h"
@interface PlayEngine : NSObject

@property(nonatomic,assign) id <PlayEngineDelegate> delegate;

-(instancetype)initWithPath:(NSString *)Path;

-(void)playWithPath:(NSString*)Path;

-(void)SeekVideo:(double)incr;

-(void)removeNotify;

@end
