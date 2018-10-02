//
//  NSString+Extension.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
-(BOOL)fj_isNilOrEmpty
{
    NSCharacterSet * emptyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n"];
    
    if (!self || [self stringByTrimmingCharactersInSet:emptyCharacterSet].length == 0) {
        return YES;
    }
    else{
        return NO;
    }
}

@end
