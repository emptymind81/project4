//
//  UIImage+Alpha.m
//  ShapedButtonDemo
//
//  Created by Dreambuild on 8/21/13.
//
//

#import "UIImage+Alpha.h"
#import "MyCategoryIVars.h"

CGContextRef CreateARGBBitmapContext (CGImageRef inImage)
{
   CGContextRef    context = NULL;
   CGColorSpaceRef colorSpace;
   void *          bitmapData;
   int             bitmapByteCount;
   int             bitmapBytesPerRow;
   
   
   size_t pixelsWide = CGImageGetWidth(inImage);
   size_t pixelsHigh = CGImageGetHeight(inImage);
   bitmapBytesPerRow   = (pixelsWide * 4);
   bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
   
   colorSpace = CGColorSpaceCreateDeviceRGB();
   if (colorSpace == NULL)
      return nil;
   
   bitmapData = malloc( bitmapByteCount );
   if (bitmapData == NULL)
   {
      CGColorSpaceRelease( colorSpace );
      return nil;
   }
   context = CGBitmapContextCreate (bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedFirst);
   if (context == NULL)
   {
      free (bitmapData);
      fprintf (stderr, "Context not created!");
   }
   CGColorSpaceRelease( colorSpace );
   
   return context;
}

@implementation UIImage(Alpha)

- (NSData*)argbData
{
   return [MyCategoryIVars fetch:self].argbData;
}

- (void)setArgbData:(NSData*)obj
{
   [MyCategoryIVars fetch:self].argbData = obj;
}

- (NSData *)ARGBData
{
   CGContextRef cgctx = CreateARGBBitmapContext(self.CGImage);
   if (cgctx == NULL)
      return nil;
   
   size_t w = CGImageGetWidth(self.CGImage);
   size_t h = CGImageGetHeight(self.CGImage);
   CGRect rect = {{0,0},{w,h}};
   CGContextDrawImage(cgctx, rect, self.CGImage);
   
   void *data = CGBitmapContextGetData (cgctx);
   CGContextRelease(cgctx);
   if (!data)
      return nil;
   
   size_t dataSize = 4 * w * h; // ARGB = 4 8-bit components
   return [NSData dataWithBytes:data length:dataSize];
}
- (BOOL)isPointTransparent:(CGPoint)point
{
   if (self.argbData == nil)
   {
      self.argbData = [self ARGBData];
   }
   if (self.argbData == nil)
   {
      return NO;
   }
   
   NSInteger pointX = trunc(point.x);
   NSInteger pointY = trunc(point.y);
   
   size_t bpp = 4;
   size_t bpr = self.size.width * 4;
   
   NSUInteger index = pointX * bpp + (pointY * bpr);
   char *rawDataBytes = (char *)[self.argbData bytes];
   
   return rawDataBytes[index] == 0;
   
}
@end
