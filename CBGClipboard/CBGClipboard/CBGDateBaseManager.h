//
//  CBGDateBaseManager.h
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class CBGPasteboardItem;

@interface CBGDateBaseManager : NSObject

@property (nonatomic, readonly, strong) NSPersistentContainer *persistentContainer;

+(instancetype)sharedInstance;

-(void)savePasteboardItem:(CBGPasteboardItem*)pasteboardItem;

-(NSMutableArray<CBGPasteboardItem*>*)fetchPasteboardItemWithMaxCount:(NSInteger)maxCount;

-(void)deleteItem:(CBGPasteboardItem*)item;

-(void)deleteAllItems;

@end
