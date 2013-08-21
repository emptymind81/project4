//
//  MyCategoryIVars.m
//  ShapedButtonDemo
//
//  Created by Dreambuild on 8/21/13.
//
//

#import "MyCategoryIVars.h"
#import <objc/runtime.h>

@implementation MyCategoryIVars

@synthesize argbData;

+ (MyCategoryIVars*)fetch:(id)targetInstance
{
   static void *compactFetchIVarKey = &compactFetchIVarKey;
   MyCategoryIVars *ivars = objc_getAssociatedObject(targetInstance, &compactFetchIVarKey);
   if (ivars == nil) {
      ivars = [[MyCategoryIVars alloc] init];
      objc_setAssociatedObject(targetInstance, &compactFetchIVarKey, ivars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
   }
   return ivars;
}

- (id)init
{
   self = [super init];
   return self;
}


@end
