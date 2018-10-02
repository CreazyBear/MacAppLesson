//
//  XWWorldSettingSelectionCell.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWWorldSettingSelectionCell.h"
#import "XWWorldSettingRowModel.h"
#import "XWModModel.h"

@interface XWWorldSettingSelectionCell()
@property (weak) IBOutlet NSPopUpButton *selections;
@property (nonatomic, strong) NSString* key;
@end


@implementation XWWorldSettingSelectionCell

-(void)bindData:(XWWorldSettingRowModel*)rowDataModel {
    
    [self.selections removeAllItems];
    [self.selections setTarget:self];
    [self.selections setAction:@selector(handleAction:)];
    
    NSArray<NSString*>* data = rowDataModel.selections;
    self.key = rowDataModel.name_en;
    [data enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.selections addItemWithTitle:obj];
    }];
    
    NSUInteger defaultIndex  = [data indexOfObject:rowDataModel.settedValue];
    [self.selections selectItemAtIndex:defaultIndex];
}

-(void)bindModSetData:(XWModModel*)rowDataModel withOptionName:(NSString*)key{
    [self.selections removeAllItems];
    [self.selections setTarget:self];
    [self.selections setAction:@selector(handleAction:)];
    NSArray * options = [rowDataModel.configItems valueForKey:key];
    if ([options isKindOfClass:[NSArray class]]) {
        [options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [obj valueForKey:@"data"];
            if (value) {
                NSString * title = @"";
                if ([value isKindOfClass:[NSNumber class]]) {
                    title = [NSString stringWithFormat:@"%@",(value)];
                }
                else {
                    title = value;
                }
                [self.selections addItemWithTitle:title];
            }
        }];
        self.key = key;
        
        id selectOption = [rowDataModel.configResults valueForKey:key];
        if (selectOption) {
            NSString * str = [NSString stringWithFormat:@"%@",(selectOption)];
            [self.selections selectItemWithTitle:str];
        }
        else{
            NSString * str = [NSString stringWithFormat:@"%@",([rowDataModel.configDefault valueForKey:key])];
            [self.selections selectItemWithTitle:str];
        }
    }
}


-(void)handleAction:(NSPopUpButton *)popBtn {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeWorldSettingValue:forKey:)]) {
        [self.delegate changeWorldSettingValue:self.selections.selectedItem.title forKey:self.key];
    }
}



@end
