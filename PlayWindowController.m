//
//  PlayWindowController.m
//  ZYAV
//
//  Created by wu weiwei on 2017/5/6.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//
#import "AppSingle.h"
#import "PlayWindowController.h"
#import "PlayViewController.h"
@interface PlayWindowController (){
    NSTrackingArea *trackingArea;
    PlayViewController*playViewController;
    NSString* playPath;
   
}
@property(nonatomic,strong) IBOutlet NSView *layView;
@end

@implementation PlayWindowController


- (instancetype)initWithWindowNibName:(NSString *)windowNibName size:(NSSize)size{
    self =  [super initWithWindowNibName:windowNibName];
    if (self) {
        if (size.width<550||380<size.height){
            self.window.minSize = size;
        }else{
            self.window.minSize = CGSizeMake(550, 380);
        }
        [self.window setContentSize:size];
        [self.window setAspectRatio:size];
        [self.window center];
    }
    playViewController = [[PlayViewController alloc]initWithNibName:@"PlayViewController" size:size];
    self.contentViewController = playViewController;
    return self;
}
-(BOOL)resignFirstResponder{
    return  YES;
}

-(void)playPath:(NSString*)path{
    playPath = path;

}

-(void)reWindowTitle:title{
    NSString*name = [[[(NSArray*)[title componentsSeparatedByString:@"/"]lastObject]componentsSeparatedByString:@"."] firstObject];
  [self.window setTitle:name];
    [self.window setMiniwindowTitle:name];
}
- (void)windowDidLoad {
    [super windowDidLoad];

  //  [self.window setOpaque:NO];
//[self.window setHidesOnDeactivate:YES];
    [self performSelector:@selector(reWindowTitle:) withObject:playPath afterDelay:0.0];
    [self.window setLevel:NSStatusWindowLevel];
  
 //   [self.window setMiniwindowTitle:@"nihao"];
    

   
    [self.window setMovableByWindowBackground:YES];

    
    [self.window setStyleMask:[self.window styleMask]|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.contentView.layer.backgroundColor = [[NSColor clearColor]CGColor];
     self.window.backgroundColor = [NSColor blackColor];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = true;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowCloseButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];

    trackingArea = [[NSTrackingArea alloc] initWithRect:playViewController.view.bounds options:
                    NSTrackingMouseMoved |
                    NSTrackingMouseEnteredAndExited |NSTrackingActiveInKeyWindow|
                    NSTrackingActiveAlways owner:playViewController  userInfo:nil];

    // 添加到View中
    [playViewController.view  addTrackingArea:trackingArea];
    [[NSNotificationCenter defaultCenter] addObserver:self.window
                                             selector:@selector(windowDidResize:)
                                                 name:NSWindowDidResizeNotification
                                               object:self];
    [self.window center];
   
    [self.window setAccessibilityMain:YES];
}

-(BOOL) canBecomeKeyWindow { return YES;}
-(BOOL) canBecomeMainWindow { return YES;}
-(BOOL) acceptsFirstResponder { return YES; }

- (void)windowDidResize:(NSNotification *)aNotification
{
//    [self resizeWindowWithContentSize:self.contentViewController.view.frame.size animated:YES];
    [playViewController.view removeTrackingArea:trackingArea];
    trackingArea = [[NSTrackingArea alloc] initWithRect:playViewController.view.bounds options:
                    NSTrackingMouseMoved |
                    NSTrackingMouseEnteredAndExited |NSTrackingActiveInKeyWindow|
                    NSTrackingActiveAlways owner:playViewController userInfo:nil];
    
    
    // 添加到View中
    [playViewController.view  addTrackingArea:trackingArea];
    
}



- (void)updateRgbImageDisplay:(CGImageRef)imageRef{
    if (playViewController) {
        [playViewController updateRgbImage:imageRef];
    }
    
}

- (void)updateCurTime:(int64_t)curTime{
    if (playViewController) {
       [playViewController updateCurTime:curTime];
    }
    
}

-(void)update_video_duration:(int64_t)duration{
    if (playViewController) {
        [playViewController update_duration:duration];
    }
    
}
//- (void)mouseEntered:(NSEvent *)event{
//    
//    [self.window setStyleMask:[self.window styleMask]|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView];
//    
//    
//}
//- (void)mouseMoved:(NSEvent *)event{
//   [self.window setStyleMask:[self.window styleMask]|NSWindowStyleMaskBorderless|NSWindowStyleMaskResizable|NSWindowStyleMaskFullSizeContentView];
//    
//    
//}

@end
