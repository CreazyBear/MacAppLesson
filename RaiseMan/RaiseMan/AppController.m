//
//  AppController.m
//  RaiseMan
//
//  Created by 熊伟 on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "AppController.h"
#import "PreferenceController.h"

@implementation AppController

+ (void)initialize
{
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    // Archive the color object
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject: [NSColor yellowColor]];
    // Put defaults in the dictionary
    [defaultValues setObject:colorAsData forKey:BNRTableBgColorKey];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:BNREmptyDocKey];
    // Register the dictionary of defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}


- (IBAction)showPreferencePanel:(id)sender
{
    // Is preferenceController nil?
    if (!_preferenceController) {
        _preferenceController = [[PreferenceController alloc] initWithWindowNibName:@"PreferenceController"];
    }
    [_preferenceController showWindow:self];
}


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    NSLog(@"applicationShouldOpenUntitledFile:");
    return [PreferenceController preferenceEmptyDoc];
}

@end
