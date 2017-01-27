//
//  BHFaceDetector.h
//  BHFaceView
//
//  Created by Brian Heller on 1/27/17.
//  Copyright © 2017 Brian Heller. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BHFaceDetector : NSObject
-(void)trainDetector:(NSString *)trainingDataPath;
-(void)findFaceInImage:(UIImage *)image completion:(void (^)(CGRect face))block;
@end
