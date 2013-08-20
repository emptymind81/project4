//
//  UIRoundRectView.m
//  Dulux
//
//  Created by Emptymind on 8/10/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "UIRoundRectView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIRoundRectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
                      rect.origin.x,
                      rect.origin.y + rect.size.height - cornerRadius);
    
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        cornerRadius);
    
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y,
                        cornerRadius);
    
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 8.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat red, green, blue, alpha;
	[self.fillColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
	CGContextSetRGBFillColor(context, red, green, blue, alpha);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
    
	[self.strokeColor getRed:&red green:&green blue:&blue alpha:&alpha];
	CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

@end
