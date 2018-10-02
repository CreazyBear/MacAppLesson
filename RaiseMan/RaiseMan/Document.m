//
//  Document.m
//  RaiseMan
//
//  Created by Bear on 2017/8/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "Document.h"
#import "Person.h"
#import "ViewController.h"


@interface Document()
@property (nonatomic, strong) NSMutableArray<Person*> *employees;
@end


@implementation Document



- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"]];
    if (self.employees) {
        ((ViewController*)self.windowControllers[0].contentViewController).employees = [self.employees mutableCopy];
        [self.employees removeAllObjects];
        self.employees = nil;
    }
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSArray * data = ((ViewController*)self.windowControllers[0].contentViewController).employees;
    return [NSKeyedArchiver archivedDataWithRootObject:data];
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    
    NSLog(@"About to read data of type %@", typeName);
    NSMutableArray *newArray = nil;
    @try {
        newArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *e) {
        NSLog(@"exception = %@", e);
        if (outError) {
            NSDictionary *d = [NSDictionary dictionaryWithObject:@"The data is corrupted."
                                                          forKey:NSLocalizedFailureReasonErrorKey];
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                            code:unimpErr
                                        userInfo:d];
        }
        return NO;
    }
    self.employees = [newArray mutableCopy];
    return YES;
    
}

+ (BOOL)autosavesInPlace {
    return YES;
}



@end
