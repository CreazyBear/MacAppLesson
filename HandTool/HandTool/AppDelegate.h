//
//  AppDelegate.h
//  HandTool
//
//  Created by 熊伟 on 2017/9/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

