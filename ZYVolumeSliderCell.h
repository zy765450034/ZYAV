//
//  TetraSliderCell.h
//  TetraKit
//
//  Created by Sadik Saidov (www.iconshots.com)
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface ZYVolumeSliderCell : NSSliderCell
{
	BOOL isPressed;
}
@property (nonatomic, strong) NSImage *knob;
@property (nonatomic, strong) NSImage *knobHighlited;
@end
