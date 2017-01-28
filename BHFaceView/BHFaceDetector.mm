//
//  BHFaceDetector.mm
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHFaceDetector.h"
#import <opencv2/objdetect.hpp>
#import <opencv2/imgproc.hpp>

using namespace cv;

@interface BHFaceDetector()
@property (nonatomic) CascadeClassifier classifier;
@property (nonatomic) dispatch_queue_t processQueue;
@property (nonatomic) BOOL ready;
@end

@implementation BHFaceDetector

/*
 Create a new object. This will initialize a classifier and get a process queue for it to perform operations on.
*/
-(instancetype)init {
    self = [super init];
    if(self) {
        NSLog(@"Initializing face detector");
        _classifier = CascadeClassifier();
        _processQueue = dispatch_get_global_queue(DISPATCH_QUEUE_SERIAL, 0);
        _ready = NO;
    }
    return self;
}

/*
 Train the detector.
*/
-(void)trainDetector:(NSString *)trainingDataPath {
    NSLog(@"Training detector");
    if(!_classifier.load([trainingDataPath cStringUsingEncoding:NSUTF8StringEncoding])){
        NSLog(@"Error loading classifier");
    }
    NSLog(@"Finished training.");
    _ready = YES;
}

-(BOOL)isReady {
    return _ready;
}
/*
 Find faces in a UIImage.
*/
-(void)findFaceInImage:(UIImage *)image completion:(void (^)(CGRect face))block {
    if(_ready) {
    // Process this on our background queue
    dispatch_async(_processQueue, ^{
        // Declare a variable to store our face location in.
        CGRect faceArea = CGRectNull;
        
        // A vector of CV rects for the classifier to read into.
        std::vector<cv::Rect> faces_vector;
        
        // Convert UIImage to Mat
        Mat mat = [self cvMatFromUIImage:image];
        
        // Groom the mat for the classifier.
        Mat frame_gray;
        cvtColor(mat, frame_gray, CV_BGR2GRAY);
        equalizeHist(frame_gray, frame_gray);
        
        // Use the classifier to find any faces in the image.
        //_classifier.detectMultiScale(frame_gray, faces_vector, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE);
        _classifier.detectMultiScale(frame_gray, faces_vector);
        
        // Check to see if any faces were found.
        if(faces_vector.size() > 0) {
            // Just grab the first face for now. We will refactor this later to maybe display an array of faces.
            cv::Rect f = faces_vector[0];
            
            // convert the cv::Rect to a CGRect so it can be used with regular ol' Objective C.
            faceArea = CGRectMake(f.x, f.y, f.width, f.height);
        }
        
        // Call the completion block
        dispatch_async(dispatch_get_main_queue(), ^{
            block(faceArea);
        });
    });
    }
}

/*
 Convert a UIImage to a cv::Mat
*/
-(Mat) cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat mat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(mat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    mat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast  | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return mat;
}

@end
