//
//  XWWorldSettingRowModel.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XWWorldSettingRowModel : NSObject <NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSString *name_ch;
@property (nonatomic, strong) NSString *name_en;
@property (nonatomic, strong) NSString *settedValue;
@property (nonatomic, strong) NSString *worldType;
@property (nonatomic, strong) NSArray *selections;


@end
