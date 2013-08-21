//
//  RoomViewController.h
//  Dulux
//
//  Created by Emptymind on 8/8/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDraggableView.h"

@interface RoomViewController : UIViewController<UIActionSheetDelegate, UIDraggableViewDelegate>

@property int seriIndex;
@property int roomIndex;

@end
