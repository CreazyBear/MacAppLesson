//
//  XWWorldConfigViewController.h
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWBaseViewController.h"

@interface XWWorldConfigViewController : XWBaseViewController

@end

@interface XWWorldListManager : NSObject<NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWWorldConfigViewController *context;
@end

@interface XWSettingListManager : NSObject<NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWWorldConfigViewController *context;
@end
