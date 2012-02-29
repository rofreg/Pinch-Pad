//
//  PinchPadMainViewController.h
//  PinchPad
//
//  Created by Ryan Laughlin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "PinchPadFlipsideViewController.h"

@class Reachability;

@protocol ImageDataDelegate
- (UIImage*)currentImage;
- (void)clear;
- (void)undo;
- (void)setDrawingTool:(int)index;
@end

@interface PinchPadMainViewController : UIViewController <PinchPadFlipsideViewControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>{
    Reachability* internetReachable;
    Reachability* hostReachable;
    bool internetActive;
    bool hostActive;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (nonatomic, assign) IBOutlet id <ImageDataDelegate> imageDataDelegate;
@property (nonatomic, assign) IBOutlet UIButton *postButton;
@property (nonatomic, assign) IBOutlet UILabel *pendingLabel;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void) checkNetworkStatus:(NSNotification *)notice;
- (void) submitQueue;
- (void) updatePendingLabel;

- (IBAction)clear:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)post:(id)sender;
- (IBAction)changeTool:(id)sender;

@end
