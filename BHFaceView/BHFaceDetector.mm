//
//  BHFaceDetector.mm
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import "BHFaceDetector.h"
#import <opencv2/objdetect.hpp>

using namespace cv;

@interface BHFaceDetector()
@property (nonatomic) CascadeClassifier classifier;
@end

@implementation BHFaceDetector

-(instancetype)init {
    self = [super init];
    if(self) {
        NSLog(@"Initializing face detector");
        _classifier = CascadeClassifier();
    }
    return self;
}
-(void)trainDetector:(NSString *)trainingDataPath {
    NSLog(@"Training detector");
    if(!_classifier.load([trainingDataPath cStringUsingEncoding:NSUTF8StringEncoding])){
        NSLog(@"Error loading classifier");
    }
    NSLog(@"Finished training.");
}
@end
