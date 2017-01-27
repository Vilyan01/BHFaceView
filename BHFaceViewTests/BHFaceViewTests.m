//
//  BHFaceViewTests.m
//  BHFaceViewTests
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BHFaceDetector.h"

@interface BHFaceViewTests : XCTestCase
@property (strong, nonatomic) BHFaceDetector *detector;
@end

@implementation BHFaceViewTests

- (void)setUp {
    [super setUp];
    _detector = [BHFaceDetector new];
    NSString *trainingDataPath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt_tree" ofType:@"xml"];
    [_detector trainDetector:trainingDataPath];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFindFaceInImage {
    // Load up the images
    NSString *obamaPath = [[NSBundle bundleForClass:self.class] pathForResource:@"obama_face" ofType:@"jpg"];
    
    UIImage *obamaImage = [UIImage imageWithContentsOfFile:obamaPath];
    
    // Create expectation for test
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for facial recognition to complete"];
    
    // Run the images through the facial recognition.
    [_detector findFaceInImage:obamaImage completion:^(CGRect face) {
        XCTAssertFalse(CGRectIsNull(face), @"It should find a face");
        [expectation fulfill];
    }];
    
    // Wait for expectations
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"Error waiting for expectation: %@", [error localizedDescription]);
        }
    }];
}

- (void)testFindFaceInImageFail {
    NSString *noFacePath = [[NSBundle bundleForClass:self.class] pathForResource:@"no_face" ofType:@"jpg"];
    UIImage *noFace = [UIImage imageWithContentsOfFile:noFacePath];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for facial recognition to complete"];

    [_detector findFaceInImage:noFace completion:^(CGRect face) {
        XCTAssertTrue(CGRectIsNull(face), @"it should not find a face");
        [expectation fulfill];
    }];
    
    // Wait for expectations
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"Error waiting for expectation: %@", [error localizedDescription]);
        }
    }];
}

@end
