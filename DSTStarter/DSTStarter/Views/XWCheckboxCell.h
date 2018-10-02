//
//  XWCheckboxCell.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/11.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol XWCheckboxCellDelegate
-(void)changeEnabled:(BOOL)enabled forKey:(NSString*)key;
@end


@interface XWCheckboxCell : NSTableCellView
@property (nonatomic, weak) id delegate;
-(void)bindDataWithKey:(NSString*)key hasEnabled:(BOOL)isEnabled;
@end
