//
//  XWMainConfigurationModel.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/8.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"
#import "XWWorldModel.h"
#import <YYModel.h>
#import "XWModModel.h"

@interface XWMainConfigurationModel : NSObject
SINGLETON_INTERFACE(XWMainConfigurationModel, defaultModel)

@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, strong) NSString* saveSlotName;
@property (nonatomic, strong) NSString* gameStyle;
@property (nonatomic, strong) NSString* gameModel;
@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) NSString* pvp;
@property (nonatomic, assign) BOOL connectModel;
@property (nonatomic, strong) NSString* roomDesc;
@property (nonatomic, strong) NSString* roomNum;
@property (nonatomic, strong) NSString* roomPassport;
@property (nonatomic, strong) NSString* masterPort;
@property (nonatomic, strong) NSMutableArray<XWModModel*> *modList;

@property (nonatomic, strong) NSMutableArray<XWWorldModel*>* worlds;
-(void)loadFromLocalModel:(XWMainConfigurationModel*)localModel;
@end
