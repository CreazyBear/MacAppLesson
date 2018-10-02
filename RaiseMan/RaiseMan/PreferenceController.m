//
//  PreferenceController.m
//  RaiseMan
//
//  Created by 熊伟 on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "PreferenceController.h"

NSString * const BNRTableBgColorKey = @"BNRTableBackgroundColor";
NSString * const BNREmptyDocKey = @"BNREmptyDocumentFlag";
NSString * const BNRColorChangedNotification = @"BNRColorChanged";

@interface PreferenceController ()

@end

@implementation PreferenceController

- (id)init {
//    self = [super initWithWindowNibName:@"PreferenceController"];
    return self;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    [_colorWell setColor: [PreferenceController preferenceTableBgColor]];
    [_checkbox setState: [PreferenceController preferenceEmptyDoc]];
}





- (IBAction)changeBackgroundColor:(id)sender
{
    NSColor *color = [_colorWell color];
    NSLog(@"Color changed: %@", color);
    [PreferenceController setPreferenceTableBgColor:color];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Sending notification");
    NSDictionary *d = [NSDictionary dictionaryWithObject:color
                                                  forKey:@"color"];
    [nc postNotificationName:BNRColorChangedNotification
                      object:self
                    userInfo:d];
}


- (IBAction)changeNewEmptyDoc:(id)sender
{
    NSInteger state = [_checkbox state];
    NSLog(@"Checkbox changed %ld", state);
    [PreferenceController setPreferenceEmptyDoc:state];
}




+ (NSColor *)preferenceTableBgColor
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *colorAsData = [defaults objectForKey:BNRTableBgColorKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}
+ (void)setPreferenceTableBgColor:(NSColor *)color
{
    NSData *colorAsData =
    [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorAsData
                                              forKey:BNRTableBgColorKey];
}
+ (BOOL)preferenceEmptyDoc
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:BNREmptyDocKey];
}
+ (void)setPreferenceEmptyDoc:(BOOL)emptyDoc
{
    [[NSUserDefaults standardUserDefaults] setBool:emptyDoc
                                            forKey:BNREmptyDocKey];
}

@end
