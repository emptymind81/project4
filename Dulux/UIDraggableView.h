//
//  UIDraggableView.h
//  Dulux
//
//  Created by Emptymind on 8/22/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIDraggableView;

@protocol UIDraggableViewDelegate <NSObject>

@required
-(void) dragView:(UIDraggableView*)dragView startDragAtParentViewPoint:(CGPoint)pt ;
-(void) dragView:(UIDraggableView*)dragView draggingAtParentViewPoint:(CGPoint)pt previousPoint:(CGPoint)previousPt;
-(void) dragView:(UIDraggableView*)dragView dropAtParentViewPoint:(CGPoint)pt ;
@end



@interface UIDraggableView : UIImageView

@property NSObject<UIDraggableViewDelegate>* delegate;

@end
