//
//  CBGPasteboardItem.m
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGPasteboardItem.h"

@implementation CBGPasteboardItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _time = [NSDate new];
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@---%@---%@",self.time,self.content,self.type];
}
@end
