//
//  AppDelegate.h
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHFaceDetector.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) BHFaceDetector *faceDetector;


@end

