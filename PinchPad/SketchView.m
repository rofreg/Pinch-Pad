//
//  SketchView.m
//  Pinch Pad
//
//  Created by Ryan Laughlin on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SketchView.h"

@implementation SketchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentSketch = nil;
        currentDrawingTool = 0;
    }
    return self;
}


- (void)drawRect:(CGRect)rect;
{   
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    // Redraw the picture thus far
    if (currentSketch != nil){
        [currentSketch drawInRect:CGRectMake(0, 0, currentSketch.size.width, currentSketch.size.height)];
    }
    
    // Draw current line
    // TODO: Bezier interpolation (http://tonyngo.net/2011/09/smooth-line-drawing-in-ios/)
    // http://stackoverflow.com/questions/5076622/iphone-smooth-sketch-drawing-algorithm
    if ([currentLine count] > 0){
        UIBezierPath* aPath = [UIBezierPath bezierPath];
        
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
    
        if (currentDrawingTool == 0) {
            CGContextSetStrokeColorWithColor (context, [[UIColor blackColor] CGColor]);
            CGContextSetFillColorWithColor (context, [[UIColor blackColor] CGColor]);
            aPath.lineWidth = 4;
        } else {
            CGContextSetStrokeColorWithColor (context, [[UIColor whiteColor] CGColor]);
            CGContextSetFillColorWithColor (context, [[UIColor whiteColor] CGColor]);
            aPath.lineWidth = 50;
        }
        
        // Draw starting point
        CGPoint p = [[currentLine objectAtIndex:0] CGPointValue];
        [aPath moveToPoint:p];
        CGContextFillEllipseInRect(context, CGRectMake(p.x - (aPath.lineWidth / 2), p.y - (aPath.lineWidth / 2), aPath.lineWidth, aPath.lineWidth));
        
        // Draw lines to all subsequent locations
        for (int i = 0; i < [currentLine count]; i++) {
            CGPoint p = [[currentLine objectAtIndex:i] CGPointValue];
            [aPath addLineToPoint:p];
        }
        
        // Draw ending dot
        p = [[currentLine objectAtIndex:([currentLine count] - 1)] CGPointValue];
        CGContextFillEllipseInRect(context, CGRectMake(p.x - (aPath.lineWidth / 2), p.y - (aPath.lineWidth / 2), aPath.lineWidth, aPath.lineWidth));
        
        [aPath stroke];
    }
    
    CGContextFlush(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Reset current line
    currentLine = [[NSMutableArray alloc] init];
    
    // Add start point
    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch locationInView:self];
    [currentLine addObject:[NSValue valueWithCGPoint:lastPoint]];
    
    [self setNeedsDisplay];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Add line point
    UITouch *touch = [touches anyObject];
    CGPoint lastPoint = [touch locationInView:self];
    [currentLine addObject:[NSValue valueWithCGPoint:lastPoint]];
    
    [self setNeedsDisplay];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Add last line point
    // UITouch *touch = [touches anyObject];
    // [currentLine addObject:[touch locationInView:self]]
    
    // Save an undo point
    undoPoint = currentSketch;
    
    // Save latest version of image
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    currentSketch = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (UIImage*)currentImage {
    // Return a UIImage of the current state of the canvas
    if (currentSketch != nil)
        NSLog(@"Returning current image");

    return currentSketch;
}

- (void)clear {
    // Clear the canvas
    undoPoint = currentSketch;
    currentSketch = nil;
    currentLine = [[NSMutableArray alloc] init];
    [self setNeedsDisplay];
    NSLog(@"Clearing...");
}

- (void)undo {
    // Step back by one line
    currentSketch = undoPoint;
    currentLine = [[NSMutableArray alloc] init];
    [self setNeedsDisplay];
}

- (void)setDrawingTool:(int)index {
    // Set the current drawing tool
    currentDrawingTool = index;
    NSLog(@"Tool set to %d", index);
}

@end
