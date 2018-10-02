//
//  ViewController.m
//  RaiseMan
//
//  Created by Bear on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "PreferenceController.h"


@interface ViewController()

@end


@implementation ViewController
static void *RMDocumentKVOContext;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _employees = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _employees = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        _employees = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleColorChange:)
                                                 name:BNRColorChangedNotification
                                               object:nil];
    
    
    [_tableView setBackgroundColor: [PreferenceController preferenceTableBgColor]];
}
- (void)handleColorChange:(NSNotification *)note
{
    NSLog(@"Received notification: %@", note);
    NSColor *color = [[note userInfo] objectForKey:@"color"];
    [_tableView setBackgroundColor:color];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}




- (IBAction)undoAction:(id)sender {
    [self.undoManager undo];
}
- (IBAction)redoAction:(id)sender {
    [self.undoManager redo];
}

- (IBAction)createEmployee:(id)sender {
    NSWindow *w = [_tableView window];
    // Try to end any editing that is taking place
    BOOL editingEnded = [w makeFirstResponder:w];
    if (!editingEnded) {
        NSLog(@"Unable to end editing");
        return; }
    NSUndoManager *undo = [self undoManager];
    // Has an edit occurred already in this event?
    if ([undo groupingLevel] > 0) {
        // Close the last group
        [undo endUndoGrouping];
        // Open a new group
        [undo beginUndoGrouping];
    }
    // Create the object
    Person *p = [_employeeController newObject];
    // Add it to the content array of ’employeeController’
    [_employeeController addObject:p];
    // Re-sort (in case the user has sorted a column)
    [_employeeController rearrangeObjects];
    // Get the sorted array
    NSArray *a = [_employeeController arrangedObjects];
    // Find the object just added
    NSUInteger row = [a indexOfObjectIdenticalTo:p];
    NSLog(@"starting edit of %@ in row %lu", p, row);
    // Begin the edit in the first column
    [_tableView editColumn:0
                       row:row
                 withEvent:nil
                    select:YES];
}

- (IBAction)removeEmployee:(id)sender
{
    NSArray *selectedPeople = [_employeeController selectedObjects];
    
    NSAlert *alert = [NSAlert alertWithMessageText:
                      @"Do you really want to remove these people?"
                                     defaultButton:@"Remove"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"%lu people will be removed.",
                      [selectedPeople count]];
    NSLog(@"Starting alert sheet");
    [alert beginSheetModalForWindow:[_tableView window]
                      modalDelegate:self
                     didEndSelector:@selector(alertEnded:code:context:)
                        contextInfo:NULL];
}

- (void)alertEnded:(NSAlert *)alert
              code:(NSInteger)choice
           context:(void *)v
{
    NSLog(@"Alert sheet ended");
    // If the user chose "Remove", tell the array controller to
    // delete the people
    if (choice == NSAlertDefaultReturn) {
        // The argument to remove: is ignored
        // The array controller will delete the selected objects
        [_employeeController remove:nil];
    }
}



-(void)setEmployees:(NSMutableArray<Person *> *)employees{
    for (Person *person in _employees) {
        [self stopObservingPerson:person];
    }
    _employees = employees;
    for (Person *person in _employees) {
        [self startObservingPerson:person];
    }}

- (void)startObservingPerson:(Person *)person
{
    [person addObserver:self
             forKeyPath:@"personName"
                options:NSKeyValueObservingOptionOld
                context:&RMDocumentKVOContext];
    [person addObserver:self
             forKeyPath:@"expectedRaise"
                options:NSKeyValueObservingOptionOld
                context:&RMDocumentKVOContext];
}

- (void)stopObservingPerson:(Person *)person
{
    [person removeObserver:self
                forKeyPath:@"personName"
                   context:&RMDocumentKVOContext];
    [person removeObserver:self
                forKeyPath:@"expectedRaise"
                   context:&RMDocumentKVOContext];
}

- (void)changeKeyPath:(NSString *)keyPath
             ofObject:(id)obj
              toValue:(id)newValue
{
    [obj setValue:newValue forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &RMDocumentKVOContext)
    {
        // If the context does not match, this message
        // must be intended for our superclass.
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    NSUndoManager *undo = [self undoManager];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    // NSNull objects are used to represent nil in a dictionary
    if (oldValue == [NSNull null]) {
        oldValue = nil;
    }
    NSLog(@"oldValue = %@", oldValue);
    [[undo prepareWithInvocationTarget:self] changeKeyPath:keyPath
                                                  ofObject:object
                                                   toValue:oldValue];
    [undo setActionName:@"Edit"];
}

- (void)insertObject:(Person *)p inEmployeesAtIndex:(NSUInteger)index {
    NSLog(@"adding %@ to %@", p, self.employees);
    // Add the inverse of this operation to the undo stack
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] removeObjectFromEmployeesAtIndex:index];
    if (![undo isUndoing]) {
        [undo setActionName:@"Add Person"];
    }
    // Add the Person to the array
    [self startObservingPerson:p];
    [self.employees insertObject:p atIndex:index];
}

- (void)removeObjectFromEmployeesAtIndex:(NSUInteger)index
{
    Person *p = [self.employees objectAtIndex:index];
    NSLog(@"removing %@ from %@", p, self.employees);
    // Add the inverse of this operation to the undo stack
    NSUndoManager *undo = [self undoManager];
    [[undo prepareWithInvocationTarget:self] insertObject:p
                                       inEmployeesAtIndex:index];
    if (![undo isUndoing]) {
        [undo setActionName:@"Remove Person"];
    }
    [self stopObservingPerson:p];
    [self.employees removeObjectAtIndex:index];
}



@end
