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
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"AvailableOperations.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"AvailableOperations" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSArray *temp = (NSArray *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    NSSet *operations = [NSSet setWithArray:temp];
    
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

+ (double)popOperandOffStack:(NSMutableArray *)stack usingDictionary:(NSDictionary *)dictionary
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]] && (dictionary != nil) &&
             [dictionary objectForKey:topOfStack]) {
        result = [[dictionary objectForKey:topOfStack] doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack usingDictionary:dictionary] + 
            [self popOperandOffStack:stack usingDictionary:dictionary];
        }
        else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack usingDictionary:dictionary] * 
            [self popOperandOffStack:stack usingDictionary:dictionary];
        }
        else if ([@"-" isEqualToString:operation]) {
            double last = [self popOperandOffStack:stack usingDictionary:dictionary];
            result = [self popOperandOffStack:stack usingDictionary:dictionary] - last;
        }
        else if ([@"/" isEqualToString:operation]) {
            double last = [self popOperandOffStack:stack usingDictionary:dictionary];
            if (last != 0) {
                result = [self popOperandOffStack:stack usingDictionary:dictionary] / last;
            }
            else result =0;
        }   
        else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack usingDictionary:dictionary]);
        }
        else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack usingDictionary:dictionary]);
        }
        else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffStack:stack usingDictionary:dictionary]);
        }
        else if ([operation isEqualToString:@"+/-"]) {
            double last = [self popOperandOffStack:stack usingDictionary:dictionary];
            if (last > 0) {
                result = - fabs(last);
            }
            else {
                result = fabs(last);
            }
        }
        else if ([operation isEqualToString:@"1/x"]) {
            result = 1/[self popOperandOffStack:stack usingDictionary:dictionary];
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
    return [self popOperandOffStack:stack usingDictionary:nil];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack usingDictionary:variableValues];
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
}

@end
