//
//  UIView+Common.m
//  Dulux
//
//  Created by Emptymind on 8/25/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end

/////////////////////////////////////////////
@implementation UIImageView(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end


/////////////////////////////////////////////
@implementation UILabel(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end



/////////////////////////////////////////////
@implementation UIButton(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end


/////////////////////////////////////////////
@implementation UITextView(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end


/////////////////////////////////////////////
@implementation CMHTableView(Common)
-(int) left
{
    return self.frame.origin.x;
}
-(int) right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(int) top
{
    return self.frame.origin.y;
}
-(int) bottom
{
    return self.frame.origin.y + self.frame.size.height;
}
-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}
@end

