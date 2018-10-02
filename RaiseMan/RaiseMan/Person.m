//
//  Person.m
//  RaiseMan
//
//  Created by Bear on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "Person.h"

@implementation Person
- (id)init {
    self = [super init];
    if (self) {
        NSArray * names = @[@"Bear",@"Mouse",@"Panda",@"Mondey"];
        NSInteger index = random()%4;
        self.expectedRaise = 0.05;
        self.personName = names[index];
        self.date = [NSString stringWithFormat:@"%@",[NSDate new]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.personName forKey:@"personName"];
    [aCoder encodeDouble:self.expectedRaise forKey:@"expectedRaise"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.personName = [aDecoder decodeObjectForKey:@"personName"];
        self.expectedRaise = [aDecoder decodeDoubleForKey:@"expectedRaise"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}
@end
