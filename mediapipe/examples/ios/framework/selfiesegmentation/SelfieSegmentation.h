//
//  SelfieSegmentation.h
//  MetalPipeDemo
//
//  Created by cute on 2021/3/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class SelfieSegmentation;
@protocol SelfieSegmentationDelegate <NSObject>

/// Provides the delegate with a new video frame.
@optional
- (void) selfieSegmentation:(SelfieSegmentation *)selfieSegmentation
     didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
                timestamp:(CMTime)timestamp;

@end


@interface SelfieSegmentation : NSObject
/// The delegate, which receives output frames.
@property(weak) id<SelfieSegmentationDelegate> delegate;
//+ (instancetype)sharedInstance;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
                timestamp:(CMTime)timestamp;

/*- (void)processCGImageFrame:(CGImageRef)cgImage
                timestamp:(CMTime)timestamp;*/



//- (void) test;
-(bool) start;
-(bool) stop;
@end

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

 CGImageRef createCGImageFromCVPixelBuffer(CVPixelBufferRef imageBuffer, NSError **error);

/// Creates a CVPixelBuffer with a copy of the contents of the CGImage. Returns nil on error, if
/// the |error| argument is not nil, *error is set to an NSError describing the failure. Caller
/// is responsible for releasing the CVPixelBuffer by calling CVPixelBufferRelease.
 CVPixelBufferRef createCVPixelBufferFromCGImage(CGImageRef image, NSError **error);
#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

NS_ASSUME_NONNULL_END
