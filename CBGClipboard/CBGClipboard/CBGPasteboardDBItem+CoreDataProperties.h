//
//  CBGPasteboardDBItem+CoreDataProperties.h
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGPasteboardDBItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CBGPasteboardDBItem (CoreDataProperties)

+ (NSFetchRequest<CBGPasteboardDBItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, retain) NSData *contentUrls;

@end

NS_ASSUME_NONNULL_END
