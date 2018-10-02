//
//  XWModModel.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/10.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LuaScriptCore.h>

@interface XWModModel : NSObject

@property (nonatomic, assign) BOOL doneAnalyse;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * folderName;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) NSString * modDescription;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * forumthread;
@property (nonatomic, strong) NSString * api_version;
@property (nonatomic, strong) NSString * dst_compatible;
@property (nonatomic, strong) NSString * dont_starve_compatible;
@property (nonatomic, strong) NSString * reign_of_giants_compatible;
@property (nonatomic, strong) NSString * all_clients_require_mod;
@property (nonatomic, strong) NSString * client_only_mod;
@property (nonatomic, strong) NSString * server_only_mod;
@property (nonatomic, strong) NSString * icon_atlas;
@property (nonatomic, strong) NSString * icon;

@property (nonatomic, strong) NSArray *configuration_options;

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSArray*> *configItems;
@property (nonatomic, strong) NSArray<NSString*> *configNames;
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSString*> *configResults;
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSString*> *configDefault;

@property (nonatomic, strong) LSCContext *context;

@property (nonatomic, assign) BOOL isEnabled;

@end
