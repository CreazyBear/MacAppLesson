//
//  XWWorldSettingSelectionCell.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class XWWorldSettingRowModel,XWModModel;

@protocol XWWorldSettingSelectionCellDelegate
-(void)changeWorldSettingValue:(NSString*)newValue forKey:(NSString*)key;
@end

@interface XWWorldSettingSelectionCell : NSTableCellView 
@property (nonatomic, weak) id delegate;
-(void)bindData:(XWWorldSettingRowModel*)rowDataModel;
-(void)bindModSetData:(XWModModel*)rowDataModel withOptionName:(NSString*)key;
@end
