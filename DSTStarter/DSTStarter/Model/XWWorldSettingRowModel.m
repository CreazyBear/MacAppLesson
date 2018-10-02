//
//  XWWorldSettingRowModel.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWWorldSettingRowModel.h"

@implementation XWWorldSettingRowModel


-(id)copyWithZone:(NSZone *)zone{
    XWWorldSettingRowModel * newModel = [XWWorldSettingRowModel new];
    newModel.name_en = self.name_en.copy;
    newModel.name_ch = self.name_ch.copy;
    newModel.settedValue = self.settedValue.copy;
    newModel.worldType = self.worldType.copy;
    newModel.selections = self.selections.copy;
    return newModel;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    XWWorldSettingRowModel * newModel = [XWWorldSettingRowModel new];
    newModel.name_en = self.name_en.copy;
    newModel.name_ch = self.name_ch.copy;
    newModel.settedValue = self.settedValue.copy;
    newModel.worldType = self.worldType.copy;
    newModel.selections = self.selections.copy;
    return newModel;
}

@end
