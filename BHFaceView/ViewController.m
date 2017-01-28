//
//  ViewController.m
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface ViewController () <AVCapturePhotoCaptureDelegate>
// Render a circle to this image view that will circle the face in the video.
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;

// AVFoundation objects we will need to use to capture images to find faces in.
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *layer;
@property (strong, nonatomic) AVCapturePhotoOutput *imageOutput;

// Facial detection properties.
@property (strong, nonatomic) BHFaceDetector *detector;
@property (strong, nonatomic) NSTimer *faceTimer;

// Debug properties
@property (strong, nonatomic) UIImage *screenshot;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set up the camera.
    [self initDetector];
    [self initCamera];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Set up the preview
    [self initPreviewLayer];
    
    // Start the preview
    [_session startRunning];
    
    // Create a timer to find them faces.
    if(!_faceTimer) {
        _faceTimer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self getSnapshotFromPreview];
        }];
    }
    
    // Add the timer to the run loop.
    [[NSRunLoop mainRunLoop] addTimer:_faceTimer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Save resources, stop running the session and timer.
    [_session stopRunning];
    [_faceTimer invalidate];
}

- (void)getSnapshotFromPreview {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    [_imageOutput capturePhotoWithSettings:settings delegate:self];
    
}

- (void)initDetector {
    self.detector = [BHFaceDetector new];
    NSString *trainingDataPath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
    [self.detector trainDetector:trainingDataPath];
    
}

- (void)initCamera {
    // Create an AVCaptureSession
    _session = [AVCaptureSession new];
    
    // Use the discovery session to find the front camera on the device.
    AVCaptureDeviceDiscoverySession *discovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    // Check to see if no devices were found.
    if([discovery devices].count == 0) {
        NSLog(@"Unable to find a front device. Try modifying the position to find the back device.");
        return;
    }
    
    // Get the front camera from the discovery session.
    AVCaptureDevice *device = [discovery devices].firstObject;
    
    // Get the input from the device.
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    // Check to see if there was an error retrieving the device input.
    if(error) {
        NSLog(@"Error getting device input: %@", [error localizedDescription]);
        return;
    }
    
    // If we have a valid input, add it to the session.
    if([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    
    // Create a photo output to capture images with.
    _imageOutput = [AVCapturePhotoOutput new];
    if([_session canAddOutput:_imageOutput]) {
        [_session addOutput:_imageOutput];
    }
}

- (void)initPreviewLayer {
    if(!_layer) {
        // Create a layer to display the video preview on and add it to our view.
        _layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        _layer.frame = self.view.frame;
        [self.view.layer addSublayer:_layer];
    }
}

#pragma mark - Photo Capture Delegate

-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error {
    if(photoSampleBuffer != NULL) {
        UIImage *image = [UIImage imageWithData:[AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer]];
        
        [_detector findFaceInImage:image completion:^(CGRect face) {
            if(!CGRectIsNull(face)) {
                NSLog(@"Found a face at origin: %f, %f", face.origin.x, face.origin.y);
            }
        }];
    }
}
@end
