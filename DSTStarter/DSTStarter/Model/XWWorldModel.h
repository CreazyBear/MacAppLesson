//
//  XWWorldModel.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XWWorldSettingRowModel;


typedef NS_ENUM(NSUInteger, XWWorldType) {
    XWWorldTypeOver,
    XWWorldTypeCave
};



@interface XWWorldModel : NSObject
//世界设置的时候完成设置
@property (nonatomic, strong) NSString * worldPath;
@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * worldId;
@property (nonatomic, assign) XWWorldType worldType;
@property (nonatomic, strong) NSMutableArray<XWWorldSettingRowModel*> *worldSettings;

//启动的时候再设置
@property (nonatomic, strong) NSString * port;

@property (nonatomic, strong) NSFileHandle * writeHandle;

@property (nonatomic, strong) NSPipe *writePipe;

@property (nonatomic, strong) NSTask * task;

@end
