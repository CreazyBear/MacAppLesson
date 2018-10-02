//
//  CBGPasteboardDBItem+CoreDataProperties.m
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGPasteboardDBItem+CoreDataProperties.h"

@implementation CBGPasteboardDBItem (CoreDataProperties)

+ (NSFetchRequest<CBGPasteboardDBItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CBGPasteboardDBItem"];
}

@dynamic content;
@dynamic time;
@dynamic type;
@dynamic contentUrls;

@end
