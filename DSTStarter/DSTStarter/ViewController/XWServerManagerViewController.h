//
//  XWServerManagerViewController.h
//  DSTStarter
//
//  Created by 熊伟 on 2017/10/5.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "XWBaseViewController.h"

@interface XWServerManagerViewController : XWBaseViewController 


@end

@interface XWPlayerListManager:NSObject <NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWServerManagerViewController *context;
@end

@interface XWAdminListManager:NSObject <NSTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, weak) XWServerManagerViewController *context;
@end

@interface XWBlockListManager:NSObject <NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, weak) XWServerManagerViewController *context;
@end
