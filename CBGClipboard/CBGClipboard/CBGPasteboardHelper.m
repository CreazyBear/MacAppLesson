//
//  CBGPasteboardHelper.m
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGPasteboardHelper.h"
#import "CBGPasteboardItem.h"
#import "NSDate+Utilities.h"

NSString * const NSPasteboardTypeMIX = @"NSPasteboardTypeMIX";
NSString * const NSPasteboardTypeCBGPath = @"NSPasteboardTypeCBGPath";
NSString * const NSPasteboardTypeCBGImage = @"NSPasteboardTypeCBGImage";

@implementation CBGPasteboardHelper

+ (CBGPasteboardItem*)transferNSPasteboard
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *possibleTypes = [pasteboard types];
    
    CBGPasteboardItem * item = [CBGPasteboardItem new];

    if ([possibleTypes containsObject:NSPasteboardTypeString])
    {
        item.content = [pasteboard stringForType:NSPasteboardTypeString];
    }
    
    if ([possibleTypes containsObject:NSFilenamesPboardType])
    {
        item.contentUrls = [pasteboard propertyListForType:NSFilenamesPboardType];
    }
    else if ([possibleTypes containsObject:NSPasteboardTypePNG])
    {
        NSData * pngData = [pasteboard dataForType:NSPasteboardTypePNG];
        NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

        NSString * filePath = [NSString stringWithFormat:@"%@/CBGPasteboard/%@.png",documentPath,[item.time longString]];
        BOOL writeResult = [[NSFileManager defaultManager] createFileAtPath:filePath contents:pngData attributes:nil];
        if (!writeResult) {
            NSLog(@"Write file fail");
        }
        
        item.contentUrls = @[filePath];
    }
    item.type = [CBGPasteboardHelper judgeType:item.contentUrls];
    return item;
}

+(NSString*)judgeType:(NSArray*)contentUrl
{
    if (contentUrl == nil) {
        return NSPasteboardTypeString;
    }
    __block NSMutableSet<NSString*> * urlType = [NSMutableSet new];
    [contentUrl enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL* pathUrl = [[NSURL alloc]initFileURLWithPath:obj];
        NSString * lastComponent = pathUrl.lastPathComponent;
        if ([lastComponent containsString:@"."])
        {
            NSString * typeString = [lastComponent componentsSeparatedByString:@"."].lastObject;
            [urlType addObject:typeString];
        }
        else
        {
            [urlType addObject:NSPasteboardTypeCBGPath];
        }
    }];
    if (urlType.count > 1)
    {
        return NSPasteboardTypeMIX;
    }
    else if(urlType.count == 1)
    {
        NSArray * urlTypeArray = [urlType allObjects];
        NSString * fileTypeString = [urlTypeArray[0] lowercaseString];
        if ([fileTypeString isEqualToString:NSPasteboardTypeCBGPath])
        {
            return NSPasteboardTypeCBGPath;
        }
        NSArray * imgTypes = @[@"jpg",@"png",@"jpeg",@"bmp"];
        if ([imgTypes containsObject:fileTypeString])
        {
            return NSPasteboardTypeCBGImage;
        }
    }
    return NSPasteboardTypeString;
}


@end
