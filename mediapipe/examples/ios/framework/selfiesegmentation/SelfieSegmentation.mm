//
//  SelfieSegmentation.m
//  MetalPipeDemo
//
//  Created by cute on 2021/3/22.
//

#import "SelfieSegmentation.h"
//#import "mediapipe/objc/MPPCameraInputSource.h"
#import "mediapipe/objc/MPPTimestampConverter.h"
#import "mediapipe/objc/MPPGraph.h"
#import "mediapipe/objc/CGImageRefUtils.h"
#import <CoreMedia/CoreMedia.h>

#include <opencv2/core/version.hpp>

#ifdef CV_VERSION_EPOCH  // for OpenCV 2.x
#include <opencv2/core/core.hpp>
#else
#include <opencv2/cvconfig.h>

#include <opencv2/core.hpp>
#endif

@interface SelfieSegmentation()<MPPGraphDelegate>
// Graph name.
/*@property(nonatomic) NSString* graphName;
// Graph input stream.
@property(nonatomic) const char* graphInputStream;
// Graph output stream.
@property(nonatomic) const char* graphOutputStream;*/
@property(nonatomic) MPPGraph* mediapipeGraph;
// Helps to convert timestamp.
@property(nonatomic) MPPTimestampConverter* timestampConverter;

@end


static const char* kInputRedStream = "red";
static const char* kInputBlueStream = "blue";
static const char* kInputGreenStream = "green";
static const char* kOutputHairMaskStream = "hair_mask_cpu";

static const char* kInputStream = "input_video";
static const char* kOutputStream = "segmentation_mask";
static NSString* const kGraphName = @"selfie_segmentation_gpu";


@implementation SelfieSegmentation
{
    // Handles camera access via AVCaptureSession library.
//  MPPCameraInputSource* _cameraSource;
    dispatch_queue_t _videoQueue;
    bool _started;
    // Render frames in a layer.
}
/*
- (void) test{
    NSLog(@"test begin");
    NSLog(@"test finished");
}


+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static SelfieSegmentation* _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[SelfieSegmentation alloc] init]; // or some other init method
        _sharedObject.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
        [_sharedObject.mediapipeGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
     //   [_sharedObject.mediapipeGraph addFrameOutputStream:kOutputHairMaskStream outputPacketType:MPPPacketTypeImageFrame];
        _sharedObject.mediapipeGraph.delegate = _sharedObject;
        _sharedObject.mediapipeGraph.maxFramesInFlight = 2;
    });
    return _sharedObject;
}


- (void)dealloc {
  self.mediapipeGraph.delegate = nil;
  [self.mediapipeGraph cancel];
  // Ignore errors since we're cleaning up.
  [self.mediapipeGraph closeAllInputStreamsWithError:nil];
  [self.mediapipeGraph waitUntilDoneWithError:nil];
}*/



-(bool) start{
    if(_started){
        return false;
    }
    
/*    self.graphName = kGraphName;//[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphName"];
    self.graphInputStream = kInputStream;
       // [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphInputStream"] UTF8String];
    self.graphOutputStream = kOutputStream;
     //   [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GraphOutputStream"] UTF8String];
    */
    self.mediapipeGraph = [[self class] loadGraphFromResource:kGraphName];
    [self.mediapipeGraph addFrameOutputStream:kOutputStream outputPacketType:MPPPacketTypePixelBuffer];
    self.mediapipeGraph.delegate = self;
    self.mediapipeGraph.maxFramesInFlight = 2;
    
    NSError* error;
    if(!_started){
        if (![self.mediapipeGraph startWithError:&error]) {
            NSLog(@"Failed to start graph: %@", error);
            _started = false;
          
        }else{
            _started = true;
        }
    }
    return _started;
}

-(bool) stop{
    
        
    if(!_started){
        return false;
    }
    self.mediapipeGraph.delegate = nil;
    [self.mediapipeGraph cancel];
    // Ignore errors since we're cleaning up.
    [self.mediapipeGraph closeAllInputStreamsWithError:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^{
        [self.mediapipeGraph waitUntilDoneWithError:nil];
    });
    
    return true;
}

+ (MPPGraph*)loadGraphFromResource:(NSString*)resource {
    // Load the graph config resource.
    NSError* configLoadError = nil;
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    if (!resource || resource.length == 0) {
        return nil;
    }
    NSURL* graphURL = [bundle URLForResource:resource withExtension:@"binarypb"];
    NSLog(@"graphURL = %@", graphURL.path);
    NSData* data = [NSData dataWithContentsOfURL:graphURL options:0 error:&configLoadError];
    if (!data) {
        NSLog(@"Failed to load MediaPipe graph config: %@", configLoadError);
        return nil;
    }
    
    // Parse the graph config resource into mediapipe::CalculatorGraphConfig proto object.
    mediapipe::CalculatorGraphConfig config;
    config.ParseFromArray(data.bytes, data.length);
    
    // Create MediaPipe graph with mediapipe::CalculatorGraphConfig proto object.
    MPPGraph* newGraph = [[MPPGraph alloc] initWithGraphConfig:config];
   
    return newGraph;
}

/*
- (void)processCGImageFrame:(CGImageRef)cgImage
                timestamp:(CMTime)timestamp{
    NSError *error = nil;
    CVPixelBufferRef pixelBuffer = createCVPixelBufferFromCGImage(cgImage, &error);
    if(error){
        NSLog(@"error = %@", error.localizedDescription);
    }
   
    [self processVideoFrame:pixelBuffer  timestamp:timestamp];
    
}*/
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
                timestamp:(CMTime)timestamp
// fromSource:(MPPInputSource*)source
{
    
    
    
  
    
    
    
  
    
    /*    else if (![self.mediapipeGraph waitUntilIdleWithError:&error]) {
     NSLog(@"Failed to complete graph initial run: %@", error);
     return;
     }
     */
    
    NSLog(@"started.");
    
    if(nil != self.mediapipeGraph){
        
        //  CVPixelBufferRetain(imageBuffer);
        
        
        mediapipe::Timestamp graphTimestamp(static_cast<mediapipe::TimestampBaseType>(
            mediapipe::Timestamp::kTimestampUnitsPerSecond * CMTimeGetSeconds(timestamp)));
        
        BOOL res =  [self.mediapipeGraph sendPixelBuffer:imageBuffer
                                              intoStream:kInputStream
                                              packetType:MPPPacketTypePixelBuffer
                                               timestamp:graphTimestamp];
    
        
        NSLog(@"send pixelBuffer success = %d", res);
        /*
        if(!res){
            return;
        }
        
        CGFloat r = 0;
        CGFloat g = 0;
        CGFloat b = 0;
        CGFloat a = 0;
        
        [color getRed:&r green:&g blue:&b alpha:&a];
      
        
        float iR = (float)r;//floor(r * 255);
        float iG = (float)g;//floor(g * 255);
        float iB = (float)b;//floor(b * 255);
        
        mediapipe::Packet rPacket = mediapipe::MakePacket<float>(iR);
        mediapipe::Packet gPacket = mediapipe::MakePacket<float>(iG);
        mediapipe::Packet bPacket = mediapipe::MakePacket<float>(iB);
        
        NSError *error = nil;
        [self.mediapipeGraph movePacket:std::move(rPacket.At(graphTimestamp))
                             intoStream:kInputRedStream
                                  error:&error];
        if(nil != error){
            NSLog(@"error = %@", error.localizedDescription);
        }else{
            NSLog(@"send packet r successfully");
        }
        
        
        [self.mediapipeGraph movePacket:std::move(gPacket.At(graphTimestamp))
                             intoStream:kInputGreenStream
                                  error:&error];
        if(nil != error){
            NSLog(@"error = %@", error.localizedDescription);
        }else{
            NSLog(@"send packet b successfully");
        }
        
        
        [self.mediapipeGraph movePacket:std::move(bPacket.At(graphTimestamp))
                             intoStream:kInputBlueStream
                                  error:&error];
        if(nil != error){
            NSLog(@"error = %@", error.localizedDescription);
        }else{
            NSLog(@"send packet g successfully");
        }
        
        
        
        */
        NSLog(@"Process commited %d.", res);
    }
    NSLog(@"Process finished.");
    
}
/*
- (void)mediapipeGraph:(MPPGraph *)graph
    didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
            fromStream:(const std::string &)streamName{
    NSLog(@"didOutputPixelBuffer");
    
}*/

/// Provides the delegate with a new video frame and time stamp.
- (void)mediapipeGraph:(MPPGraph *)graph
    didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
              fromStream:(const std::string &)streamName
             timestamp:(const mediapipe::Timestamp &)timestamp{
    NSString *str = [NSString stringWithCString:streamName.c_str()
                                       encoding:[NSString defaultCStringEncoding]];
    NSLog(@"core didOutputPixelBuffer %@", str);
    if (streamName == kOutputStream) {
        // Display the captured image on the screen.
        CVPixelBufferRetain(pixelBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"core didOutputPixelBuffer begin.");
            
            //  [_renderer renderPixelBuffer:pixelBuffer];
            if ([self.delegate
                 respondsToSelector:@selector
                 (selfieSegmentation:didOutputPixelBuffer:timestamp:)]) {
                
                [self.delegate selfieSegmentation:self
                           didOutputPixelBuffer:pixelBuffer
                                      timestamp:kCMTimeZero];
            }
            NSLog(@"core didOutputPixelBuffer finished.");
            CVPixelBufferRelease(pixelBuffer);
        });
    }
}



/// Provides the delegate with a raw packet.
- (void)mediapipeGraph:(MPPGraph *)graph
       didOutputPacket:(const mediapipe::Packet &)packet
            fromStream:(const std::string &)streamName{
    
    NSString *str = [NSString stringWithCString:streamName.c_str()
                                       encoding:[NSString defaultCStringEncoding]];
    
    NSLog(@"core didOutputPacket %@", str);
    

    const auto& maskMat = packet.Get<cv::Mat>();
    cv::Size s = maskMat.size();
    int rows = s.height;
    int cols = s.width;
    NSLog(@"core didOutputPacket finished. %d %d", rows, cols);
}



//<MPPGraphDelegate>
- (void)mediapipeGraph:(MPPGraph*)graph
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
            fromStream:(const std::string&)streamName {
    NSString *str = [NSString stringWithCString:streamName.c_str()
                                           encoding:[NSString defaultCStringEncoding]];
        
        NSLog(@"core didOutputPixelBuffer %@ no timestamp", str);
        
    
    
    if (streamName == kOutputStream) {
        // Display the captured image on the screen.
        CVPixelBufferRetain(pixelBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"core didOutputPixelBuffer begin no timestamp.");
            //  [_renderer renderPixelBuffer:pixelBuffer];
            if ([self.delegate
                 respondsToSelector:@selector
                 (selfieSegmentation:didOutputPixelBuffer:timestamp:)]) {
                
                [self.delegate selfieSegmentation:self
                           didOutputPixelBuffer:pixelBuffer
                                      timestamp:kCMTimeZero];
            }
            NSLog(@"core didOutputPixelBuffer finished no timestamp.");
            CVPixelBufferRelease(pixelBuffer);
        });
    }
    
}



@end


CGImageRef createCGImageFromCVPixelBuffer(CVPixelBufferRef imageBuffer, NSError **error){
    return CreateCGImageFromCVPixelBuffer(imageBuffer, error);
}

/// Creates a CVPixelBuffer with a copy of the contents of the CGImage. Returns nil on error, if
/// the |error| argument is not nil, *error is set to an NSError describing the failure. Caller
/// is responsible for releasing the CVPixelBuffer by calling CVPixelBufferRelease.
CVPixelBufferRef createCVPixelBufferFromCGImage(CGImageRef image, NSError **error){
    return CreateCVPixelBufferFromCGImage(image, error);
}
