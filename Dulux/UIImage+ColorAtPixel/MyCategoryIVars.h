//
//  MyCategoryIVars.h
//  ShapedButtonDemo
//
//  Created by Dreambuild on 8/21/13.
//
//

#import <Foundation/Foundation.h>

@interface MyCategoryIVars : NSObject

@property (strong,nonatomic) NSData* argbData;
+ (MyCategoryIVars*)fetch:(id)targetInstance;

@end
