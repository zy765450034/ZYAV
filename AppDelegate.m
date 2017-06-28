//
//  AppDelegate.m
//  ZYAV
//
//  Created by wu weiwei on 2017/5/4.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//
#import "AppSingle.h"
#import "AppDelegate.h"
#import "PlayEngine.h"
#import "PlayEngineDelegate.h"
#import "PlayWindowController.h"
#import "MetadataWindowController.h"
#import "DonationWindowController.h"
@interface AppDelegate ()<PlayEngineDelegate>
@property(nonatomic,strong) PlayEngine               *engine;
@property(nonatomic,weak) PlayWindowController       *player;
@property(nonatomic,strong) MetadataWindowController *metadatavc;
@property(nonatomic,strong) DonationWindowController *donationvc;
@property(nonatomic,strong) NSString                 *rulPath;
@property(nonatomic,strong) IBOutlet NSMenuItem      *metaMenu;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   
    [self notificationAddObserver];
    [AppSingle sharedInstance];
    // Insert code here to initialize your application
}

- (IBAction)openPlayer:(id)sender {
    
    
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"mp4", @"FLV",@"mp3",@"WAV",@"ASF",@"QuickTime",@"mov",@"m4a",@"3gp",@"3g2",@"caf",@"swf", nil];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setResolvesAliases:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setTitle:@"Open Media Files"];
    [openPanel setAllowsOtherFileTypes:YES];
    [openPanel setAllowedFileTypes:fileTypes];
    if ([openPanel runModal] == NSFileHandlingPanelOKButton){
        NSURL*url = [[openPanel URLs] objectAtIndex:0];
        NSString *fileUrl = [url path];
        if (_rulPath!=nil) {
            if ([_rulPath isEqualToString:fileUrl]) {
                return;
            }
        }else{
            _rulPath = fileUrl;
        }
    if (_engine == nil) {
        _engine = [[PlayEngine alloc] initWithPath:fileUrl];
        _engine.delegate = self;
        
    }else{
        [_engine playWithPath:fileUrl];
    }
        
        
    }
    if (_player) {
        [_player.window close];
        _player = nil;
        _metadatavc = nil;
        
    }
}

- (IBAction)mediaInformation:(id)sender {
    if (_player != nil) {
        _metadatavc = [[MetadataWindowController alloc]initWithWindowNibName:@"MetadataWindowController"];
        [_metadatavc showWindow:self];
    }
    
}

- (IBAction)donation:(id)sender {

    NSString*url =@"https://www.paypal.me/wuweiwei";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];

}

-(void) application:(NSApplication *)theApplication openFiles:(NSArray *)filenames
{
    BOOL isDir = NO;
    NSApplicationDelegateReply reply = NSApplicationDelegateReplyFailure;
    if (_rulPath!=nil) {
        if ([_rulPath isEqualToString:[filenames objectAtIndex:0]]) {
            return;
        }else{
            _rulPath = [filenames objectAtIndex:0];
        }
    }else{
        _rulPath = [filenames objectAtIndex:0];
    }
    // 这里判断文件是否存在，是为了给command line arguments做准备
    if ([[NSFileManager defaultManager] fileExistsAtPath:[filenames objectAtIndex:0] isDirectory:&isDir]) {
        if (isDir) {
            if (_engine != nil) {
               
                 [_engine playWithPath:[filenames objectAtIndex:0]];
            }else{

                _engine = [[PlayEngine alloc] initWithPath:[filenames objectAtIndex:0]];
                _engine.delegate = self;
            }
           
        } else {
            if (_engine != nil) {
                
                [_engine playWithPath:[filenames objectAtIndex:0]];
                
                
            }else{
                _engine = [[PlayEngine alloc] initWithPath:[filenames objectAtIndex:0]];
                _engine.delegate = self;

            }
           
        }
        reply = NSApplicationDelegateReplySuccess;
    }
    [theApplication replyToOpenOrPrint:reply];
    
    if (_player) {
        [_player.window close];
        _player = nil;
        _metadatavc = nil;

    }
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)notificationAddObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeWindow:)
                                                 name:CloseWindowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPlayWindow:)
                                                 name:ShowWindowNotification
                                               object:nil];
    
}


-(void)show_window_size:(int)width height:(int)height{
//    self.window.minSize = CGSizeMake(610, 410);
    if (width<550||380<height) {
        if (width>height) {
            height = 550*height/width;
            width = 550;
        }else{
            height = 550*height/width;
            width = 550;
            
        }
        
        
    }
    
    if (_player == nil) {
         NSSize size = NSMakeSize(width, height);
        _player = [[PlayWindowController alloc]initWithWindowNibName:@"PlayWindowController" size:size];
        [_player showWindow:self];
        NSString *urlPath = [@"file://" stringByAppendingString:_rulPath];
        
         urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL*url = [NSURL URLWithString:urlPath];
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
    }
    NSRect rect = NSMakeRect(0,0,width, height);
    [_player.window setContentSize:NSMakeSize(width, height)];
    [_player.window setAspectRatio:NSMakeSize(width, height)];
    [_player.window center];
    [self update_title];
  
        [_metaMenu setTarget:self];
        [_metaMenu setAction:@selector(mediaInformation:)];
  
}

-(void)update_rgb_image_display:(CGImageRef)imageRef{
    
    if (_player) {
        [_player updateRgbImageDisplay:imageRef];
    }
}
-(void)update_cur_time:(int64_t)cur_time{
    [_player updateCurTime:cur_time];
}

-(void)video_metadata_duration:(int64_t)duration{
    [_player update_video_duration:duration];
}

-(void)showPlayWindow:(NSNotification*)n{
    
    if (_player == nil) {
       
        _player = [[PlayWindowController alloc]initWithWindowNibName:@"PlayWindowController"];
        [_player showWindow:self];
        
    }
    
}
- (void)closeWindow:(NSNotification*)n{
    [_player.window setCanHide:YES];
    [_engine removeNotify];
    //加个延时先让ffmpeg 线程退出
    int64_t nsec = 0.10;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( nsec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _rulPath = nil;
        _player = nil;
        _metadatavc = nil;
        _engine = nil;
        [_metaMenu setTarget:nil];
        [_metaMenu setAction:nil];
    });
}


- (void)update_title{
    
    NSString*title =  [[[(NSArray*)[_rulPath componentsSeparatedByString:@"/"]lastObject]componentsSeparatedByString:@"."] firstObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoTitileNotification object:title];
    
}
@end
