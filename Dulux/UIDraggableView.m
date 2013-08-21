//
//  UIDraggableView.m
//  Dulux
//
//  Created by Emptymind on 8/22/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "UIDraggableView.h"

@implementation UIDraggableView
{
    CGPoint m_offset;
    CGRect m_origin_frame;
    bool has_moved;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        has_moved = false;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    
    m_offset = [aTouch locationInView: self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!has_moved)
    {
        m_origin_frame = self.frame;
    }
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self];
    CGPoint previousLocation = [aTouch previousLocationInView:self];
    self.frame = CGRectOffset(self.frame, location.x-previousLocation.x, location.y- previousLocation.y);
    
    if (self.delegate)
    {
        CGPoint location_in_parent_view = [aTouch locationInView:self.superview];
        [self.delegate dragView:self draggingAtParentViewPoint:location_in_parent_view];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (has_moved)
    {
        [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
        self.frame = m_origin_frame;
        [UIView commitAnimations];
    }
    
    if (self.delegate)
    {
        UITouch *aTouch = [touches anyObject];
        CGPoint location_in_parent_view = [aTouch locationInView:self.superview];
        [self.delegate dragView:self dropAtParentViewPoint:location_in_parent_view];
    }
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    
    m_offset = [aTouch locationInView: self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
    self.frame = CGRectMake(location.x-m_offset.x, location.y-m_offset.y,
                            self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}*/

@end
