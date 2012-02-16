//
//  PinchPadFlipsideViewController.h
//  PinchPad
//
//  Created by Ryan Laughlin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PinchPadFlipsideViewController;

@protocol PinchPadFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(PinchPadFlipsideViewController *)controller;
@end

@interface PinchPadFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <PinchPadFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
