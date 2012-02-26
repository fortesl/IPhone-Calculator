//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Luis Fortes on 1/24/12.
//  Copyright (c) 2012 LIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperatorOrVariable:(NSString *)operatorOrVariable;
- (double)performOperation:(NSString *)operation;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;
- (void)clearStack;

@property (nonatomic, readonly) id program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;


@end
