//
//  PreferenceController.h
//  RaiseMan
//
//  Created by 熊伟 on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const BNRTableBgColorKey;
extern NSString * const BNREmptyDocKey;
extern NSString * const BNRColorChangedNotification;


@interface PreferenceController : NSWindowController
@property (weak) IBOutlet NSColorWell *colorWell;
@property (weak) IBOutlet NSButton *checkbox;

- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeNewEmptyDoc:(id)sender;


+ (NSColor *)preferenceTableBgColor;
+ (void)setPreferenceTableBgColor:(NSColor *)color;
+ (BOOL)preferenceEmptyDoc;
+ (void)setPreferenceEmptyDoc:(BOOL)emptyDoc;
@end
