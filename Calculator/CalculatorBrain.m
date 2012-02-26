//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Luis Fortes on 1/24/12.
//  Copyright (c) 2012 LIM. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
static NSDictionary *_dictionary;
static NSSet *_validOperations;

- (NSMutableArray *) programStack
{
    if (_programStack == nil) {
        _programStack = [[NSMutableArray alloc] init ];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];    
}

- (void)pushOperatorOrVariable:(NSString *)operatorOrVariable
{
    [self.programStack addObject:operatorOrVariable];
}

- (double)performOperation:(NSString *)operation
{
    [self pushOperatorOrVariable:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    [self pushOperatorOrVariable:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

- (id)program
{
    return [self.programStack copy];
}

- (NSSet *)validOperations
{
    NSSet *operations = [NSSet setWithObjects:
                         @"+", 
                         @"*",
                         @"-",
                         @"/",
                         @"sin",
                         @"cos",
                         @"sqrt",
                         @"+/-",
                         @"1/x",
                         nil];
    
    return operations;
}

- (id)init
{
    if (self = [super init]) {
        _validOperations = [self validOperations];
    }
    return self;
}
         
+ (NSString *)descriptionOfProgram:(id)program
{
    NSArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program copy];
    }
    
    return [stack description];
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]] && 
             [_dictionary objectForKey:topOfStack]) {
        result = [[_dictionary objectForKey:topOfStack] doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if ([@"-" isEqualToString:operation]) {
            double last = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - last;
        }
        else if ([@"/" isEqualToString:operation]) {
            double last = [self popOperandOffStack:stack];
            if (last != 0) {
                result = [self popOperandOffStack:stack] / last;
            }
            else result =0;
        }   
        else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"+/-"]) {
            double last = [self popOperandOffStack:stack];
            if (last > 0) {
                result = - fabs(last);
            }
            else {
                result = fabs(last);
            }
        }
        else if ([operation isEqualToString:@"1/x"]) {
            result = 1/[self popOperandOffStack:stack];
        }

    }
    
    return result;
}

+ (double) runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    _dictionary = [variableValues copy];
    return [self popOperandOffStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{    
    NSMutableSet *mSet = [NSMutableSet setWithCapacity:1];
    NSMutableArray *stack;
    id topOfStack;
    NSString *topString;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        while ((topOfStack = [stack lastObject])) {
            [stack removeLastObject];
            if ([topOfStack isKindOfClass:[NSString class]]) {
                topString = topOfStack;
                if (!([_validOperations containsObject:topString])) {
                    [mSet addObject:topString];
                }
            }
        }
        return [mSet copy];
    }
    return nil;
}

- (void)clearStack
{
    [self.programStack removeAllObjects];
    self.programStack = nil;
    _dictionary = nil;
}

@end
