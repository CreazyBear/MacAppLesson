//
//  AppController.h
//  RaiseMan
//
//  Created by 熊伟 on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PreferenceController;
@interface AppController : NSObject

@property (nonatomic, strong) PreferenceController *preferenceController;

- (IBAction)showPreferencePanel:(id)sender;

@end
