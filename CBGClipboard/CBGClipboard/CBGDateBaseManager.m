//
//  CBGDateBaseManager.m
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGDateBaseManager.h"
#import <CoreData/CoreData.h>
#import "CBGPasteboardItem.h"

#import "CBGPasteboardDBItem+CoreDataClass.h"
#import "CBGPasteboardDBItem+CoreDataProperties.h"



static NSString * const entityName = @"CBGPasteboardDBItem";

@interface CBGDateBaseManager()
@property (nonatomic, readwrite, strong) NSPersistentContainer *persistentContainer;

@end

@implementation CBGDateBaseManager

static CBGDateBaseManager * instance = nil;

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL]init];
        
    });
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}


- (NSPersistentContainer *)persistentContainer {
    if (_persistentContainer == nil) {
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"CBGModel"];
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    
    return _persistentContainer;
}

- (void)saveAction
{
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        // Customize this code block to include application-specific recovery steps.
        [[NSApplication sharedApplication] presentError:error];
    }
}

-(NSMutableArray<CBGPasteboardItem*>*)fetchPasteboardItemWithMaxCount:(NSInteger)maxCount
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc]initWithEntityName:entityName];
    [fetchRequest setFetchLimit:maxCount];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    NSError * error = nil;
//http://commandshift.co.uk/blog/2014/04/24/its-not-your-fault/
//    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray<CBGPasteboardDBItem *> *managedObj = [self.persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%@",error);
    }
    __block NSMutableArray<CBGPasteboardItem*>* items = [NSMutableArray new];
    [managedObj enumerateObjectsUsingBlock:^(CBGPasteboardDBItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBGPasteboardItem * ele = [CBGPasteboardItem new];
        ele.time = obj.time;
        ele.type = obj.type;
        ele.content = obj.content;
        if (obj.contentUrls) {
            ele.contentUrls = [NSUnarchiver unarchiveObjectWithData:obj.contentUrls];
        }
        [items addObject:ele];
    }];
    return items;
}

-(void)savePasteboardItem:(CBGPasteboardItem*)pasteboardItem
{
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    CBGPasteboardDBItem * newObj = [[CBGPasteboardDBItem alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    newObj.time = pasteboardItem.time;
    newObj.type = pasteboardItem.type;
    newObj.content = pasteboardItem.content;
    if (pasteboardItem.contentUrls && pasteboardItem.contentUrls.count > 0) {
        newObj.contentUrls = [NSArchiver archivedDataWithRootObject:pasteboardItem.contentUrls];
    }
    [self saveAction];
}

-(void)deleteItem:(CBGPasteboardItem*)item
{
    //1.创建一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    //2.创建查询谓词（查询条件）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time = %@",item.time];
    //3.给查询请求设置谓词
    request.predicate = predicate;
    //4.查询数据
    NSArray *arr = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    //5.删除数据
    [self.persistentContainer.viewContext deleteObject:arr.firstObject];
    //6.同步到数据库
    [self saveAction];
}

-(void)deleteAllItems
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSArray *arr = [self.persistentContainer.viewContext executeFetchRequest:request error:nil];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.persistentContainer.viewContext deleteObject:obj];
    }];
    
    [self saveAction];
}


@end
