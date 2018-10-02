//
//  XWWorldModel.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWWorldModel.h"
#import "XWWorldSettingRowModel.h"

@implementation XWWorldModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.worldSettings = [NSMutableArray new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"worldSettings" : [XWWorldSettingRowModel class] };
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"port", @"task",@"writePipe",@"writeHandle"];
}
@end
