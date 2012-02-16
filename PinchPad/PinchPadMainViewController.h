//
//  PinchPadMainViewController.h
//  PinchPad
//
//  Created by Ryan Laughlin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinchPadFlipsideViewController.h"

@interface PinchPadMainViewController : UIViewController <PinchPadFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
