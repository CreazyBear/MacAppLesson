//
//  Utils.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/8.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * finishedBasicConfigNotification = @"finishedBasicConfigNotification";
static NSString * userDefaultSaveSlotKey = @"userDefaultSaveSlotKey";
static NSString * userDefaultSaveSlotListKey = @"userDefaultSaveSlotListKey";

@interface Utils : NSObject

@property (nonatomic, strong, class, readonly) NSArray *styleName;
@property (nonatomic, strong, class, readonly) NSArray *modeName;

@property (nonatomic, strong, class, readonly) NSArray * freqency_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * starting_swaps_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * swaps_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * disease_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * speed_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * day_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * season_length_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * season_start_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * size_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * branching_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * loop_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * other_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * complexity_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * specialevent_descriptions;
@property (nonatomic, strong, class, readonly) NSArray * default_descripitions;
@property (nonatomic, strong, class, readonly) NSArray * petrification_descriptions;

+(NSString *)documentPath;
+(void)createSaveSlotWithName:(NSString*)slotName;
+(NSString *)currentSaveSlotPath;
+(NSString *)saveSlotPath:(NSString*)saveSlotName;
+(int)getFreePort;
+(int)getFreePort2:(int)startPosition;

+(void)createDirectoryAtPath:(NSString*)path;
+(void)deleteDirectoryAtPath:(NSString*)path;
+(BOOL)checkConfigModel;






@end
