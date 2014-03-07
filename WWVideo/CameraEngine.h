
#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@protocol CameraEngineDelegate <NSObject>
- (void)captureDidComplete:(NSURL *)url;
@end

@interface CameraEngine : NSObject

+ (CameraEngine*) engine;
- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;

- (void) startCapture;
- (void) pauseCapture;
- (void) stopCapture;
- (void) resumeCapture;

@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;
@property (nonatomic, strong) id<CameraEngineDelegate> delegate;

@end
