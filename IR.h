
#ifndef IR_H
#define IR_H

#include <stdio.h>
#include <string>
#include <map>

#define OP_GREATER       1
#define OP_LESS          2
#define OP_LESS_EQUAL    3
#define OP_GREATER_EQUAL 4
#define OP_EQUAL         5
#define OP_NOT_EQUAL     6

#define OP_BIT_AND       7
#define OP_BIT_OR        8
#define OP_BIT_XOR       9

#define OP_LOGICAL_AND   10
#define OP_LOGICAL_OR    11

static std::map<std::string, double> symbolTable;

// Function declarations
double performBinaryOperation(double lhs, double rhs, int op);
double performLogicalOperations(double lhs, double rhs, int op);
double performBitwiseOperations(double lhs, double rhs, int op);
double performLogicalCompoundOperations(double lhs, double rhs, int op);
double performNotOperations(double lhs);
void executeSwitch(double switchVal, const std::map<double, std::string>& caseBlocks, const std::string& defaultBlock);
void executeIf(double condition);
void print(const char* format, const char* value);
void print(const char* format, double value);
void setValueInSymbolTable(const char* id, double value);
double getValueFromSymbolTable(const char* id);

#endif
