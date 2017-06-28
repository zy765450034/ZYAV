//
//  MetadataWindowController.m
//  ZYAV
//
//  Created by wu weiwei on 2017/6/21.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//
#import "AppSingle.h"
#import "MetadataWindowController.h"

@interface MetadataWindowController ()
@property(nonatomic,strong) IBOutlet NSTextFieldCell *tile;
@property(nonatomic,strong) IBOutlet NSTextFieldCell *video;
@property(nonatomic,strong) IBOutlet NSTextFieldCell *audio;
@end

@implementation MetadataWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
     [self.window setTitle:NSLocalizedString(@"media information",@"")];
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    NSString* path = [[AppSingle sharedInstance] path];
    NSString*title =  [(NSArray*)[path componentsSeparatedByString:@"/"]lastObject];
    [_tile setTitle:title];
    NSString* video =  [[AppSingle sharedInstance] videoFormat];
    [_video setTitle:video];
    NSString* audio =  [[AppSingle sharedInstance] audioFormat];
    [_audio setTitle:audio];
    [self.window setLevel:NSStatusWindowLevel];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
