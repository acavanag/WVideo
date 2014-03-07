//
//  ACMovieMaker.m
//  PoliticalWall
//
//  Created by Andrew J Cavanagh on 9/17/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACMovieMaker.h"
#import "ACTapSensor.h"
#import "MBProgressHUD.h"
#import "ACCDMgr.h"
@import QuartzCore;
@import AVFoundation;

@interface ACMovieMaker ()
{
    MBProgressHUD *hud;
    ACTapSensor *tapSensor;
    NSTimer *maxTimer;
    BOOL recording;
    BOOL paused;
    float time;
    
    NSURL *videoURL;
    AVAssetImageGenerator *imageGenerator;
}
@property (nonatomic, strong) IBOutlet UIView *cameraView;
@property (nonatomic, strong) IBOutlet UIView *recordLight;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@end

@implementation ACMovieMaker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tapSensor = [[ACTapSensor alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.recordLight.layer setCornerRadius:5.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[CameraEngine engine] startup];
    [self startCamera];
}

#pragma mark - Actions

- (IBAction)savePressed:(id)sender
{
    [self finishRecording];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Thumbnail Generation

- (void)generateThumbnailFromAsset:(AVURLAsset *)asset
{
    imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CMTime thumbtime = kCMTimeZero;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded)
        {
            UIImage *image = [UIImage imageWithCGImage:im scale:1 orientation:UIImageOrientationRight];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval modifier = CFAbsoluteTimeGetCurrent();
                    NSURL *vURL = [[[ACCDMgr sharedInstance] applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"v_%f.mp4", modifier]];
                    NSURL *iURL = [[[ACCDMgr sharedInstance] applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"i_%f", modifier]];
                    
                    [[NSFileManager defaultManager] moveItemAtURL:videoURL toURL:vURL error:nil];
                    [imageData writeToURL:iURL atomically:NO];

                    Video *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:[ACCDMgr sharedInstance].context];
                    newVideo.date = [NSDate date];
                    newVideo.path = [vURL absoluteString];
                    newVideo.image = [iURL absoluteString];
                    
                    [[ACCDMgr sharedInstance].context save:nil];
                    
                    [hud hide:YES];
                    hud = nil;
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
        }
        else
        {
            NSLog(@"%@", [error description]);
        }
    };
    
    [imageGenerator setMaximumSize:CGSizeMake(320, 320)];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbtime]] completionHandler:handler];
}

#pragma mark - Camera

- (void)startCamera
{
    AVCaptureVideoPreviewLayer *preview = [[CameraEngine engine] getPreviewLayer];
    [preview removeFromSuperlayer];
    [preview setFrame:self.cameraView.bounds];
    [self.cameraView.layer addSublayer:preview];
    
    [[CameraEngine engine] setDelegate:self];
    [self.cameraView addGestureRecognizer:tapSensor];
}

- (void)handleTap:(ACTapSensor *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (!recording)
        {
            [self startRecording];
            recording = YES;
        }
        else
        {
            [self resumeRecording];
        }
        [self.recordLight setBackgroundColor:[UIColor redColor]];
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        if (recording)
        {
            [self pauseRecording];
            [self.recordLight setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - HUD

- (void)activateHUD
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Submiting video...";
        hud.detailsLabelText = nil;
    });
}

- (void)deactivateHUD
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [hud hide:YES afterDelay:0.0];
    });
}

#pragma mark - Camera Control

- (void)startRecording
{
    if (!maxTimer) maxTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [[CameraEngine engine] startCapture];
}

- (void)finishRecording
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [maxTimer invalidate];
        maxTimer = nil;
        self.progressView.progress = 1.0f;
    });
    [[CameraEngine engine] stopCapture];
    [self.cameraView removeGestureRecognizer:tapSensor];
    [self.recordLight setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)pauseRecording
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [maxTimer invalidate];
        maxTimer = nil;
    });
    [[CameraEngine engine] pauseCapture];
}

- (void)resumeRecording
{
    [[CameraEngine engine] resumeCapture];
    if (!maxTimer) maxTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

#pragma mark - Timer

- (void)handleTimer:(NSTimer *)timer
{
    time++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (time/100.0f);
    });
    
    if (time >= 100.0f)
    {
        [maxTimer invalidate];
        [self.cameraView removeGestureRecognizer:tapSensor];
        [self.recordLight setBackgroundColor:[UIColor lightGrayColor]];
        [[[UIAlertView alloc] initWithTitle:@"Time's Up!" message:@"No more time for you." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - Delegates

- (void)captureDidComplete:(NSURL *)url
{
    videoURL = url;
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
    [self generateThumbnailFromAsset:asset];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
