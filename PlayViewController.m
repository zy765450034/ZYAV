//
//  PlayViewController.m
//  ZYAV
//
//  Created by wu weiwei on 2017/5/4.
//  Copyright © 2017年 wuweiwei. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "PlayerDelegate.h"
#import "PlayViewController.h"
#import "AppSingle.h"
#import "LXMasterVolume.h"



#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <simd/simd.h>


static const vector_float2 K_QUAD_VERTS[4] =
{
    {-1.0f, -1.0f},
    {-1.0f,  1.0f},
    {1.0f, -1.0f},
    {1.0f,  1.0f}
};

static const vector_float2 K_QUAD_UVS[4] =
{
    {0.0f, 1.0f},
    {0.0f, 0.0f},
    {1.0f, 1.0f},
    {1.0f, 0.0f}
};



@interface PlayViewController (){
    NSTrackingArea *trackingArea;
   
    float nsec;
    int hideInterval;
    double currentTime;
    
    
    id<MTLDevice>                   mDevice;
    
    MTLRenderPipelineDescriptor*    mPipelineDescriptor;
    id<MTLRenderPipelineState>      mPipelineState;
    id<MTLCommandQueue>             mCommandQueue;
    
    id<MTLBuffer>                   mQuadVerts;
    id<MTLBuffer>                   mQuadUVs;
    CAMetalLayer*                   mMetalLayer;
    CVMetalTextureCacheRef          mMetalTextureCache;
    int paused;                     /* 0:播放 1:暂停 2:处理滑动条之前状态 */
    
}
@property(nonnull,strong) IBOutlet NSTextField *titleText;
@property(nonnull,strong) IBOutlet NSTextField *currentText;
@property(nonnull,strong) IBOutlet NSTextField *durationText;
@property(nonnull,strong) IBOutlet NSView *titleView;
@property (nonnull,strong) IBOutlet NSSlider *scrubberSlider;
@property (nonnull,strong) IBOutlet NSSlider *volumeSlider;
@property (nonnull,strong) IBOutlet NSButton *playAndPausedBtn;
@property (nonnull,strong) IBOutlet NSButton *miniBtn;
@property (nonnull,strong) IBOutlet NSButtonCell *fullBtn;
@property (nonnull,strong) IBOutlet NSImageView *centerLogo;
@property (strong) IBOutlet NSView *playerView;

@end

@implementation PlayViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil size:(NSSize)size{
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        [self.view setFrameSize:size];
    }
    return self;
}
- (void)mouseEntered:(NSEvent *)event{

    hideInterval = 300;
    [_titleView setAlphaValue:1.0];
    [_playerView setAlphaValue:1.0];
  
    
}
-(void)mouseDown:(NSEvent *)theEvent{
    
    
}
- (void)mouseMoved:(NSEvent *)event{
    hideInterval = 300;
    if (_titleView.alphaValue == 1.0) return;
    [_titleView setAlphaValue:1.0];
    [_playerView setAlphaValue:1.0];
 
}
- (BOOL)acceptsFirstMouse:(NSEvent *)event{
    return YES;
}
- (void)mouseExited:(NSEvent *)event{

    [_titleView setAlphaValue:0.0];
    [_playerView setAlphaValue:0.0];
 
}



-(BOOL) canBecomeKeyWindow {
    return YES;
}
-(BOOL) canBecomeMainWindow {
    return YES;
}
-(BOOL) acceptsFirstResponder {
    return YES;
}

- (id<MTLTexture>) createTextureFromImage:(CGImageRef) imageRef device:(id<MTLDevice>) device
{
  
//        CGImageSourceRef sourcea = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
//        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourcea, 0, NULL);
//    
//        CFRelease(sourcea);
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
        CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
        //    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
//    int   bytesPerRow = (bitsPerPixel / 8) * width;
    
        size_t bytesPerRow = 4*width;
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        
        CGContextRef context = CGBitmapContextCreate( NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
        
        if( !context )
        {
            NSLog(@"Failed to load image, probably an unsupported texture type");
            return nil;
        }
        
        CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), imageRef );
        CGColorSpaceRelease(colorSpace);
        CFRelease(imageRef);
        MTLPixelFormat format = MTLPixelFormatRGBA8Unorm;
        if( bitsPerComponent == 16 )
            format = MTLPixelFormatRGBA16Unorm;
        else if( bitsPerComponent == 32 )
            format = MTLPixelFormatRGBA32Float;
    
        MTLTextureDescriptor *texDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:format
                                                                                           width:width
                                                                                          height:height
                                                                                       mipmapped:YES];
        id<MTLTexture> texture = [device newTextureWithDescriptor:texDesc];
        
    [texture replaceRegion:MTLRegionMake2D(0, 0, width, height)
               mipmapLevel:0
                 withBytes:CGBitmapContextGetData(context)
               bytesPerRow:4 * width];
        //    MTLPixelForma
        CGContextRelease(context);
    
        return texture;
    
}

- (void) renderScene:(id<MTLTexture>)texture
{
    
    if (mMetalLayer ==nil) {
        return;
    }
    id<CAMetalDrawable> drawable = [mMetalLayer nextDrawable];
    
    // Create Command Encoder
    id<MTLCommandBuffer> commandBuffer = [mCommandQueue commandBuffer];
    
    MTLRenderPassDescriptor* descriptor = [MTLRenderPassDescriptor new];
    
    descriptor.colorAttachments[0].texture = drawable.texture;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    descriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 0.0, 1.0);
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id <MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: descriptor];
    [commandEncoder setRenderPipelineState:mPipelineState];
    
    [commandEncoder setVertexBuffer:mQuadVerts offset:0 atIndex:0 ];
    [commandEncoder setVertexBuffer:mQuadUVs offset:0 atIndex:1 ];
    
    [commandEncoder setFragmentTexture:texture atIndex:0];
    
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
    [commandEncoder endEncoding];
    
    [commandBuffer presentDrawable: drawable];
    
    [commandBuffer commit];
    
    [commandBuffer waitUntilCompleted];
    
    [texture release];
}

-(void)viewDidAppear{
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:
                    NSTrackingMouseMoved |
                    NSTrackingMouseEnteredAndExited |NSTrackingActiveInKeyWindow|
                    NSTrackingActiveAlways owner:self  userInfo:nil];
    [self.view  addTrackingArea:trackingArea];
}

-(void)viewDidLoad{
   
    [super viewDidLoad];
    hideInterval = 300;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:NSWindowDidExitFullScreenNotification object:nil];

     _playerView.layer.cornerRadius = 5;

    [self.view.window setMovableByWindowBackground:YES];

    [self.view.layer setBackgroundColor:[[NSColor clearColor]CGColor]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"LXMasterVolumeChangedNotification"
                                               object:nil];
    [self volumeChanged:nil];
    startMasterVolumeChangeNotification();


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sliderStartTracking:)
                                                 name:SliderStartTrackingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sliderContinueTracking:)
                                                 name:SliderContinueTrackingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sliderStopTracking:)
                                                 name:SliderStopTrackingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTitle:)
                                                 name:VideoTitileNotification
                                               object:nil];
    
    mDevice = MTLCreateSystemDefaultDevice();
    
    // Create command queue
    mCommandQueue = [mDevice newCommandQueue];
    
    // Create pipeline descriptor
    mPipelineDescriptor = [MTLRenderPipelineDescriptor new];
    mPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Init the screen quad and uv buffers
    mQuadVerts = [mDevice newBufferWithBytes:K_QUAD_VERTS
                                      length:sizeof(K_QUAD_VERTS)
                                     options:MTLResourceOptionCPUCacheModeDefault];
    
    mQuadUVs = [mDevice newBufferWithBytes:K_QUAD_UVS
                                    length:sizeof(K_QUAD_UVS)
                                   options:MTLResourceOptionCPUCacheModeDefault];
    
    // Get the default library to setup descriptor
    id <MTLLibrary> lib = [mDevice newDefaultLibrary];
    mPipelineDescriptor.vertexFunction = [lib newFunctionWithName:@"VertexShader"];
    mPipelineDescriptor.fragmentFunction = [lib newFunctionWithName:@"FragmentShader"];
    
    mPipelineState = [mDevice newRenderPipelineStateWithDescriptor:mPipelineDescriptor error:nil];
    
    // Create texture from image
    [self setMetalTextureCache];
    
    // create metal layer to render on
   
}
- (void)setMetalTextureCache {

    CVMetalTextureCacheFlush(mMetalTextureCache, 0);
    CVReturn err = CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, mDevice, NULL, &mMetalTextureCache);
    if (err) {
        NSLog(@">> ERROR: Could not create a texture cache");
        assert(0);
    }
}
- (void) viewDidDisappear{
    [[NSNotificationCenter defaultCenter]removeObserver:@"LXMasterVolumeChangedNotification"];
    
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SliderStartTrackingNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SliderContinueTrackingNotification  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SliderStopTrackingNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VideoTitileNotification  object:nil];
    
    
}

-(IBAction)closeAction:(id)sender{
    
   
    [self.view.window close];
    [self close];
}
- (void)enterFullScreen:(NSNotification *)notification{
   
    [_miniBtn setHidden:YES];

    [_fullBtn setImage:[NSImage imageNamed:@"min_screen_button"]];
    [self.view.window setLevel:NSNormalWindowLevel];
}
- (void)exitFullScreen:(NSNotification *)notification{
  
   [_miniBtn setHidden:NO];
    [_fullBtn setImage:[NSImage imageNamed:@"full_screen_button"]];
   [self.view.window setLevel:NSStatusWindowLevel];
}

- (void)close{
    
//    ffplayself = nil;
//    is->quit = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:CloseWindowNotification object:nil];
    
}
- (IBAction)mini:(id)sender {
    [self.view.window setIsMiniaturized:YES];
}
- (IBAction)isFullScreen:(id)sender {
    
    [self.view.window setLevel:NSNormalWindowLevel];
    [self.view.window toggleFullScreen:self];
    
    // [self.view.window performZoom:sender];
}
- (IBAction)increaseVolume:(id)sender{
    CGFloat volume=getMasterVolume()*100.0;
    if (volume>=100) {
        return;
    }
    volume = volume+10;
    setMasterVolume(volume/100.0);
    [_volumeSlider setFloatValue:volume];
}
- (IBAction)lowVolume:(id)sender{
    CGFloat volume=getMasterVolume()*100.0;
    if (volume<=0) {
        return;
    }
    volume = volume-10;
    setMasterVolume(volume/100.0);
    [_volumeSlider setFloatValue:volume];
}

- (void)volumeChanged:(NSNotification*)n
{
    CGFloat volume=getMasterVolume()*100.0;

    [_volumeSlider setFloatValue:volume];
}
- (IBAction)setVolume:(NSSlider*)sender;{
    CGFloat volume=[sender floatValue]/100.0;
    setMasterVolume(volume);
    [self volumeChanged:nil];
}



-(void)updateTitle:(NSNotification*)notification{
    NSString * title = [notification object];
    _titleText.stringValue = title;
    NSString*name = [[[(NSArray*)[title componentsSeparatedByString:@"/"]lastObject]componentsSeparatedByString:@"."] firstObject];
    [self.view.window setTitle:name];
    [self.view.window setMiniwindowTitle:name];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mMetalLayer == nil) {
            [_centerLogo setHidden:NO];
        }
    });
    
    
}

-(void)sliderStartTracking:(NSNotification *)notification{
    if (paused==1) {
        paused = 2;
    }else if (paused==0){
        paused = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:TogglePauseNotification object:nil];
        
    }

    [_playAndPausedBtn setImage:[NSImage imageNamed:paused ? @"play_button":@"pause_button"]];
}

-(void)sliderContinueTracking:(NSNotification *)notification{
    
    
    
}

-(void)sliderStopTracking:(NSNotification *)notification{
   
    double time = (_scrubberSlider.floatValue - currentTime);
    currentTime = _scrubberSlider.floatValue;
    
    NSNumber*num = [[NSNumber alloc]initWithDouble:time];
    [[NSNotificationCenter defaultCenter] postNotificationName:SeekVideoNotification object:num];
    
    
    if (paused == 2) {
        paused = 1;
        
    }
    if (paused == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TogglePauseNotification object:nil];
        
    }
    [_playAndPausedBtn setImage:[NSImage imageNamed:paused ? @"play_button":@"pause_button"]];
}

- (IBAction)fast:(id)sender {
    NSButton*fastBtn = (NSButton*)sender;
    fastBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( nsec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
         [[NSNotificationCenter defaultCenter] postNotificationName:StreamSeekNotification object:[[NSNumber alloc]initWithDouble:10.0]];

        
    });
    nsec = 0.15;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( nsec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        fastBtn.enabled = YES;;
        
    });
}


- (IBAction)back:(id)sender {
    NSButton*backBtn = (NSButton*)sender;
    backBtn.enabled = NO;
    
    nsec = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( nsec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    [[NSNotificationCenter defaultCenter] postNotificationName:StreamSeekNotification object:[[NSNumber alloc]initWithDouble:-10.0]];
        
    });
    
    
     nsec = 0.15;

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( nsec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        backBtn.enabled = YES;;
       
    });
    
}

- (IBAction)playAndPaused:(id)sender {
    paused = !paused;
    [[NSNotificationCenter defaultCenter] postNotificationName:TogglePauseNotification object:nil];
    
    [((NSButton*)sender) setImage:[NSImage imageNamed:paused ? @"play_button":@"pause_button"]];
    
    
}


- (CGImageRef) convertImage:(NSImage *)image {
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    
    return imageRef;
}
-(void)upload_yvu:(CGImageRef )image width:(int)width height:(int)height {


}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)updateRgbImage:(CGImageRef)imageRef{
    
    id<MTLTexture>  mTexture = [self createTextureFromImage:imageRef device:mDevice];
    
    [self upload_MTLTexture:mTexture];
    
}

- (void)updateCurTime:(int64_t)curTime{
    _currentText.stringValue = [self formatSeconds:(curTime)/1000000];
    currentTime = curTime/1000000;
    [_scrubberSlider setFloatValue:curTime/1000000];
    if (hideInterval==0) {
        [_titleView setAlphaValue:0.0];
        [_playerView setAlphaValue:0.0];
        return;
    }else if(hideInterval < 0){
        return;
    }
    hideInterval--;
}

-(void)update_duration:(int64_t)duration{
    _durationText.stringValue = [self formatSeconds:(duration)/1000000];
    _scrubberSlider.minValue = 0/1000000;
    _scrubberSlider.maxValue = (duration)/1000000;
}

-(void)upload_MTLTexture:(id<MTLTexture>)mTexture{
   
    if (mMetalLayer == nil) {
      
        mMetalLayer = [CAMetalLayer layer];
        mMetalLayer.device = mDevice;
        mMetalLayer.contentsGravity =  kCAGravityResizeAspect;
        mMetalLayer.backgroundColor = [[NSColor blackColor] CGColor];
        [self.view setLayer:mMetalLayer];
    }

    [self renderScene:mTexture];

}

@end
