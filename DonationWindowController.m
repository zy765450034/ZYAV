//
//  DonationWindowController.m
//  ZYAV
//
//  Created by wu weiwei on 2017/6/22.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//

#import "DonationWindowController.h"

@interface DonationWindowController ()

@end

@implementation DonationWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setTitle:NSLocalizedString(@"donation",@"")];
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
