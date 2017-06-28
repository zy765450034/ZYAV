//
//  UIColor+Hex.h
//  ZYAV
//
//  Created by wu weiwei on 2017/4/9.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSColor (Hex)
// 透明度固定为1，以0x开头的十六进制转换成的颜色
+ (NSColor *)colorWithHex:(long)hexColor;
// 0x开头的十六进制转换成的颜色,透明度可调整
+ (NSColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
// 颜色转换三：iOS中十六进制的颜色（以#开头）转换为UIColor
+ (NSColor *) colorWithHexString: (NSString *)color;
@end
