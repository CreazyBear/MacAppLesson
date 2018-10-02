//
//  ViewController.h
//  RaiseMan
//
//  Created by Bear on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Person;

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *employeeController;
@property (nonatomic, strong) NSMutableArray<Person*> *employees;

- (void)setEmployees:(NSMutableArray<Person*>*)employees;
- (void)insertObject:(Person *)p inEmployeesAtIndex:(NSUInteger)index;
- (void)removeObjectFromEmployeesAtIndex:(NSUInteger)index;
- (IBAction)removeEmployee:(id)sender;
@end

