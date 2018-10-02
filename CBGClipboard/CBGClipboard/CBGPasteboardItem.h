//
//  CBGPasteboardItem.h
//  CBGClipboard
//
//  Created by Bear on 2017/8/25.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface CBGPasteboardItem : NSObject

@property (nonatomic, strong) NSDate *time;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, strong) NSArray *contentUrls;

@end
