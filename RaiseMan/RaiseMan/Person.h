//
//  Person.h
//  RaiseMan
//
//  Created by Bear on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject<NSCoding>

@property (nonatomic, assign) CGFloat expectedRaise;
@property (nonatomic, copy) NSString* personName;
@property (nonatomic, copy) NSString *date;
@end
