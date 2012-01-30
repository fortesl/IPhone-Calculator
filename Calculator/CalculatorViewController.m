//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Luis Fortes on 1/24/12.
//  Copyright (c) 2012 LIM. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, readonly) int MaximumNumberOfCharactersInMonitor;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize monitor = _monitor;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize MaximumNumberOfCharactersInMonitor = _MaximumNumberOfCharactersInMonitor;

- (CalculatorBrain *) brain
{
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (int) MaximumNumberOfCharactersInMonitor
{
    _MaximumNumberOfCharactersInMonitor = 25;
    return _MaximumNumberOfCharactersInMonitor;
}

- (void)displayInMonitor:(NSString *)input
{
    if ((self.monitor.text.length + input.length) >=
        self.MaximumNumberOfCharactersInMonitor) {
            self.monitor.text = [self.monitor.text substringFromIndex:input.length];
    }
    
    if (!self.monitor.text.length) {
        self.monitor.text = input;
    }
    else {
        self.monitor.text = [NSString stringWithFormat:@"%@ %@", self.monitor.text, input];
    }
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self displayInMonitor:self.display.text];
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    if ([sender.currentTitle isEqualToString:@"."]) {
        if ([self.display.text rangeOfString:@"."].location != NSNotFound)
            return;
        if (!self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }
    else if ([sender.currentTitle isEqualToString:@"pi"]) {
        NSNumber *number = [NSNumber numberWithDouble:M_PI];
        self.display.text = [number stringValue]; 
        [self enterPressed];
        return;
    }
    
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:
                            sender.currentTitle];
    }
    else {
        self.display.text = [sender currentTitle];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self displayInMonitor:sender.currentTitle];
}

- (IBAction)singleOperandOperatorPressed:(UIButton *)sender 
{
    double value;
    
    [self displayInMonitor:self.display.text];
    [self displayInMonitor:sender.currentTitle];
    
    if ([sender.currentTitle isEqualToString:@"sin"]) {
        value = sin([self.display.text doubleValue]);
    }
    else if ([sender.currentTitle isEqualToString:@"cos"]) {
        value = cos([self.display.text doubleValue]);
    }
    else if ([sender.currentTitle isEqualToString:@"sqrt"]) {
        value = sqrt([self.display.text doubleValue]);
    }
    else if ([sender.currentTitle isEqualToString:@"+/-"]) {
        if ([self.display.text rangeOfString:@"-"].location != NSNotFound) {
            value = fabs([self.display.text doubleValue]);
        }
        else {
            value = - fabs([self.display.text doubleValue]);
        }
    }
    else if ([sender.currentTitle isEqualToString:@"1/x"]) {
        value = 1/[self.display.text doubleValue];
    }
    
    self.display.text = [NSString stringWithFormat:@"%g", value];
    [self.brain pushOperand:value];
    self.userIsInTheMiddleOfEnteringANumber = NO;    
}

- (IBAction)clearAll 
{
    self.monitor.text = @"";
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearStack];
    self.brain = nil;
}

@end
