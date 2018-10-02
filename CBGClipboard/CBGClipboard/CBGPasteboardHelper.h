//
//  CBGPasteboardHelper.h
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

extern NSString * const NSPasteboardTypeMIX;
extern NSString * const NSPasteboardTypeCBGPath;
extern NSString * const NSPasteboardTypeCBGImage;

@class CBGPasteboardItem;

@interface CBGPasteboardHelper : NSObject

+ (CBGPasteboardItem*)transferNSPasteboard;

@end
