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
@property (nonatomic) BOOL userEnteredVariables;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *variablesDictionary;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize programDisplay = _monitor;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variablesDictionary = _variablesDictionary;
@synthesize userEnteredVariables = _userEnteredVariables;

- (NSDictionary *) variablesDictionary
{
    if (_variablesDictionary == nil) {
        NSArray *values;
        values = [NSArray arrayWithObjects:
                  [NSNumber numberWithDouble:3.0],
                  [NSNumber numberWithDouble:4.0], 
                  [NSNumber numberWithDouble:6.0], nil];
        
        NSArray *keys;
        keys = [NSArray arrayWithObjects:
                @"X", @"Y", @"Z", nil ];
                
        _variablesDictionary = [NSDictionary dictionaryWithObjects: values forKeys:keys];
    }
    return _variablesDictionary;
}

- (CalculatorBrain *)brain
{
    if (_brain == nil) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)variablePressed:(UIButton *)sender
{
    [self.brain pushOperatorOrVariable:sender.currentTitle];
    self.userEnteredVariables = YES;
    
    NSArray *programVariables = [[CalculatorBrain variablesUsedInProgram:self.brain.program] allObjects];
    
    self.variableDisplay.text = @"";
    for (NSString *v in programVariables) {
        if (!self.variableDisplay.text.length) {
            self.variableDisplay.text = [NSString stringWithFormat:@"%@ = %g",
                                         v, [[self.variablesDictionary valueForKey:v] doubleValue]];
        }
        else {
            self.variableDisplay.text = [NSString stringWithFormat:@"%@   %@ = %g",
                                         self.variableDisplay.text, v, [[self.variablesDictionary valueForKey:v] doubleValue]];
        }
    }
    self.userIsInTheMiddleOfEnteringANumber = NO;
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
    double result = 0;
    [self.brain pushOperatorOrVariable:sender.currentTitle];
    if (self.userEnteredVariables) {
        result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.variablesDictionary];
    }
    else {
        result = [CalculatorBrain runProgram:self.brain.program];
    }
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)clearAll 
{
    self.programDisplay.text = @"";
    self.display.text = @"0";
    self.variableDisplay.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearStack];
    self.brain = nil;
    self.variablesDictionary = nil;
    self.userEnteredVariables = NO;
}

@end
