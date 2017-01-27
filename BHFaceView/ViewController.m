//
//  ViewController.m
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
// Render a circle to this image view that will circle the face in the video.
@property (weak, nonatomic) IBOutlet UIImageView *overlayView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Set up the camera
    [self initCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initCamera {
    // Create an AVCaptureSession
    AVCaptureSession *session = [AVCaptureSession new];
    
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
    if([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    // Create a layer to display the video preview on and add it to our view.
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    
    // Start the session.
    [session startRunning];
}


@end
