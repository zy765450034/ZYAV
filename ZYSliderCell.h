//
//  ZYSliderCell.h
//  ZYAV
//
//  Created by wu weiwei on 2017/5/22.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ZYSliderCell : NSSliderCell
{
    BOOL isPressed;
}
@property (nonatomic, strong) NSImage *knob;
@property (nonatomic, strong) NSImage *knobHighlited;
@end
