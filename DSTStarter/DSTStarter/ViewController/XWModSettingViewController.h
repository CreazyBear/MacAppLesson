//
//  XWModSettingViewController.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/10.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWBaseViewController.h"

@interface XWModSettingViewController : XWBaseViewController


@end

@interface XWModListManager :NSObject <NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWModSettingViewController *context;
@end

@interface XWModSetManager :NSObject <NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWModSettingViewController *context;
@end
