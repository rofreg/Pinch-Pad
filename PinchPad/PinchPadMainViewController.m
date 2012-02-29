//
//  PinchPadMainViewController.m
//  PinchPad
//
//  Created by Ryan Laughlin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PinchPadMainViewController.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>

@implementation PinchPadMainViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize imageDataDelegate = _imageDataDelegate;
@synthesize postButton = _postButton;
@synthesize pendingLabel = _pendingLabel;
@synthesize locationManager = _locationManager;


#define ALERTVIEW_CLEAR_TAG     100

-(void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    if([alertView tag] == ALERTVIEW_CLEAR_TAG) {
        if (buttonIndex == 0) { // Cancel
            NSLog(@"Delete was cancelled by the user");
        } else {
            [self.imageDataDelegate clear];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"pinchpad.com"];
    [hostReachable startNotifier];
    
    // Start tracking location
    [[self locationManager] startUpdatingLocation];
    
    // Update pending label
    [self updatePendingLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}




#pragma mark Location stuff

- (CLLocationManager *)locationManager {
    
    if (locationManager != nil) {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    
    return locationManager;
}





#pragma mark Network stuff

// Instructions from http://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-iphone-sdk
-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            hostActive = YES;
            
            break;
        }
    }
    
    //((UIButton*)self.postButton).enabled = hostActive;
    
    // If internet has turned on, try submitting the queue
    if (hostActive)
        [self submitQueue];
}

- (void) updatePendingLabel
{
    // Get current number of objects in queue; if any, set label to display number
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Sketches" 
                                                  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request 
                                              error:&error];
    NSString *pendingLabelText;
    
    if ([objects count] == 0)
        pendingLabelText = @"";
    else if ([objects count] == 1)
        pendingLabelText = @"1 post pending";
    else
        pendingLabelText = [NSString stringWithFormat:@"%d posts pending", [objects count]];
    
    self.pendingLabel.text = pendingLabelText;
}




#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(PinchPadFlipsideViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
    self.flipsidePopoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
//    if (self.flipsidePopoverController) {
//        [self.flipsidePopoverController dismissPopoverAnimated:YES];
//        self.flipsidePopoverController = nil;
//    } else {
//        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
//    }
}



#pragma mark - Button actions

- (IBAction)clear:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: nil
                          message: @"Clear the canvas?"
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Clear", nil];
    alert.tag = ALERTVIEW_CLEAR_TAG;
    [alert show];
}

- (IBAction)undo:(id)sender
{
    [self.imageDataDelegate undo];
}

- (IBAction)changeTool:(id)sender{
    NSLog(@"Changing tool...");
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    [self.imageDataDelegate setDrawingTool:[segmentedControl selectedSegmentIndex]];
}

- (IBAction)post:(id)sender
{
    if ([self.imageDataDelegate currentImage] != nil){
        CLLocation *location = [locationManager location];
        NSNumber *latitude, *longitude;
        if (location == nil || [[NSDate date] timeIntervalSinceDate: location.timestamp] > 1800){
            // If no location, or location is 30+ minutes old
            latitude = [NSNumber numberWithDouble:0];
            longitude = [NSNumber numberWithDouble:0];
        } else {
            CLLocationCoordinate2D coordinate = [location coordinate];
            latitude = [NSNumber numberWithDouble:coordinate.latitude];
            longitude = [NSNumber numberWithDouble:coordinate.longitude];
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newSketch;
        newSketch = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Sketches"
                      inManagedObjectContext:context];
        [newSketch setValue:[NSDate date] forKey:@"created_at"];
        [newSketch setValue:latitude forKey:@"latitude"];
        [newSketch setValue:longitude forKey:@"longitude"];
        [newSketch setValue:UIImagePNGRepresentation([self.imageDataDelegate currentImage]) forKey:@"image"];
        
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            // Handle the error.
        }
        
        // Submit any sketches in the queue
        [self submitQueue];
        
        // Clear the canvas
        [self.imageDataDelegate clear];
    }
    
//    
//    
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You have an internet connection"
//                                                          message:@"This should convert the SketchView to a png file and submit it to the server. (It doesn't do this yet.)"
//                                                         delegate:self
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
        
        
}


- (IBAction)submitQueue
{
    // Only try if we have an internet connection
    if (hostActive)
    {    
        // Get all items in queue
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Sketches" 
                                                      inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request 
                                                  error:&error];
        
        for (NSManagedObject *s in objects){
            // create request
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [request setHTTPShouldHandleCookies:NO];
            [request setTimeoutInterval:30];
            [request setHTTPMethod:@"POST"];
            [request setURL:[NSURL URLWithString:@"http://localhost:3000/sketches"]];
            
            NSString *boundaryString = @"DA3C48F2446B2FB88DFB21B61BC75D8249AB634DBF4EE4EAF0D3CB20F08E04D4";
            
            // set Content-Type in HTTP header
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryString];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            // post body
            NSMutableData *body = [NSMutableData data];
            
            // Simple params (location data, etc)
            NSMutableDictionary *_params = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"✓", @"utf8",
                                            [s valueForKey:@"latitude"], @"sketch[latitude]",
                                            [s valueForKey:@"longitude"], @"sketch[longitude]",
                                            [s valueForKey:@"created_at"], @"sketch[created_at]",
                                            @"reindeer_flotilla", @"password",
                                            nil];
            
            // add image data
            NSData *imageData = [s valueForKey:@"image"];
            if (imageData) {
                NSLog(@"Writing image data to POST request");
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"sketch.png\"\r\n", @"sketch[image]"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:imageData]];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            // add params (all params are strings)
            for (NSString *param in _params) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            
            // set the content-length
            NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            
            NSURLResponse* response;
            NSError* error = nil;
            
            //Capturing server response
            NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString* resultBody = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            
            if ([resultBody isEqualToString:@"success"])
                [[self managedObjectContext] deleteObject:s];  // Remove this item from queue
            else
                NSLog(@"Error: %@", error);
            
            NSLog(@"Response: %@", response);
        }
    }
    
    [self updatePendingLabel];
}


@end
