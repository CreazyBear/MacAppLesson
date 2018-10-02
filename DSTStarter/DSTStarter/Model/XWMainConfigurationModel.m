//
//  XWMainConfigurationModel.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/8.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWMainConfigurationModel.h"

@implementation XWMainConfigurationModel
SINGLETON_IMPLEMENTION(XWMainConfigurationModel, defaultModel);


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"worlds" : [XWWorldModel class],
             @"modList" : [XWModModel class]
             };
}

-(NSMutableArray<XWWorldModel *> *)worlds{
    if (!_worlds) {
        _worlds = [NSMutableArray new];
    }
    return _worlds;
}

-(NSMutableArray<XWModModel *> *)modList {
    if (!_modList) {
        _modList = [NSMutableArray new];
    }
    return _modList;
}

-(void)loadFromLocalModel:(XWMainConfigurationModel*)localModel {
    _defaultModel = localModel;
    _defaultModel.loaded = YES;
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"loaded"];
}

@end
