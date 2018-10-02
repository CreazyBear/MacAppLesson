//
//  ViewController.m
//  Random
//
//  Created by 熊伟 on 2017/8/18.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()
@property (weak) IBOutlet NSButton *seed;
@property (weak) IBOutlet NSButton *generate;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButtonCell *star;

@property (nonatomic, assign) NSInteger count;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)awakeFromNib{
    NSDate * now = [NSDate new];
    [self.textField setObjectValue:now];
    
}
- (IBAction)handleStarClicked:(id)sender {
}

- (IBAction)seed:(id)sender {
    // Seed the random number generator with the time
    srandom((unsigned)time(NULL));
    [self.textField setStringValue:@"Generator seeded"];
}

- (IBAction)generate:(id)sender {
    // Generate a number between 1 and 100 inclusive
    NSInteger generated;
    generated = (int)(random() % 100) + 1;
    NSLog(@"generated = %ld", generated);
    // Ask the text field to change what it is displaying
    [self.textField setIntegerValue:generated];
}


- (void)increment:(id)sender
{
    self.count++;
    [self.textField setIntegerValue:self.count];
}



@end
