//
//  NSImage+CBGExtension.m
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "NSImage+CBGExtension.h"

@implementation NSImage (CBGExtension)

-(NSImage*)imageWithTargetHeight:(CGFloat)height
{
    
    CGFloat rate = self.size.height/self.size.width;
    CGFloat width = height / rate;
    CGSize size = CGSizeMake(width, height);
    
    NSImage * newImage = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        CGRect destinationRect = CGRectMake(0, 0, width, height);
        CGRect originRect = CGRectMake(0, 0, self.size.width, self.size.height);
        [self drawInRect:destinationRect fromRect:originRect operation:NSCompositingOperationCopy fraction:1.0 ];
        return YES;
    }];
    return newImage;
}



@end
