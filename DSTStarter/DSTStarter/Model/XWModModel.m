//
//  XWModModel.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/10.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWModModel.h"

@implementation XWModModel



+ (NSArray *)modelPropertyBlacklist {
    return @[@"configuration_options",@"context",@"doneAnalyse"];
}

@end
