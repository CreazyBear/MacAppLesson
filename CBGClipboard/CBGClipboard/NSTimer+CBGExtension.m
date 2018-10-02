//
//  NSTimer+CBGExtension.m
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "NSTimer+CBGExtension.h"

@implementation NSTimer (CBGExtension)
-(void)pause
{
     [self setFireDate:[NSDate distantFuture]];
}

-(void)play
{
     [self setFireDate:[NSDate distantPast]];
}
@end
