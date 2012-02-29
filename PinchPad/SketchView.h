//
//  SketchView.h
//  Pinch Pad
//
//  Created by Ryan Laughlin on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchPadMainViewController.h"

@interface SketchView : UIView <ImageDataDelegate>{
    int currentDrawingTool;
    NSMutableArray* currentLine; 
    UIImage* undoPoint;
    UIImage* currentSketch;
}

@end
