
#include "IR.h"
#include <iostream>

// Function implementations
double performBinaryOperation(double lhs, double rhs, int op) {
    switch(op) {
        case '+':
            return lhs + rhs;
        case '-':
            return lhs - rhs;
        case '*':
            return lhs * rhs;
        case '/':
            if (rhs != 0) { // Check for division by zero
                return lhs / rhs;
            } else {
                fprintf(stderr, "Error: Division by zero\n");
                exit(EXIT_FAILURE);
            }
        default:
            fprintf(stderr, "Error: Unknown operator\n");
            exit(EXIT_FAILURE);
    }
}

double performLogicalOperations(double lhs, double rhs, int op) {
    switch(op) {
        case OP_GREATER:
            return (lhs > rhs) ? 1.0 : 0.0;
        case OP_LESS:
            return (lhs < rhs) ? 1.0 : 0.0;
        case OP_LESS_EQUAL:
            return (lhs <= rhs) ? 1.0 : 0.0;
        case OP_GREATER_EQUAL:
            return (lhs >= rhs) ? 1.0 : 0.0;
        case OP_EQUAL:
            return (lhs == rhs) ? 1.0 : 0.0;
        case OP_NOT_EQUAL:
            return (lhs != rhs) ? 1.0 : 0.0;
        default:
            fprintf(stderr, "Error: Unknown operator\n");
            exit(EXIT_FAILURE);
    }
}

double performBitwiseOperations(double lhs, double rhs, int op) {
    switch(op) {
        case OP_BIT_AND:
            return (double)((int)lhs & (int)rhs);
        case OP_BIT_OR:
            return (double)((int)lhs | (int)rhs);
        case OP_BIT_XOR:
            return (double)((int)lhs ^ (int)rhs);
        default:
            fprintf(stderr, "Error: Unknown bitwise operator\n");
            exit(EXIT_FAILURE);
    }
}

double performLogicalCompoundOperations(double lhs, double rhs, int op) {
    switch(op) {
        case OP_LOGICAL_AND:
            return (lhs != 0.0) && (rhs != 0.0); // Lazy evaluation enabled
        case OP_LOGICAL_OR:
            return (lhs != 0.0) || (rhs != 0.0); // Lazy evaluation enabled
        default:
            fprintf(stderr, "Error: Unknown logical operator\n");
            exit(EXIT_FAILURE);
    }
}

double performNotOperations(double lhs) {
    return (double)(~(int)lhs); // Unary NOT on lhs
}

void executeSwitch(double switchVal, const std::map<double, std::string>& caseBlocks, const std::string& defaultBlock) {
    auto it = caseBlocks.find(switchVal);
    if (it != caseBlocks.end()) {
        printf("%s", it->second.c_str());
    } else {
        if (!defaultBlock.empty()) {
            printf("%s", defaultBlock.c_str());
        }
    }
}

void executeIf(double condition) {
    if (condition == 1.000000) {
        printf("The if condition was true, executing the block...\n");
    } else {
        printf("The if condition was false, skipping the block.\n");
    }
}

void print(const char* format, const char* value) {
    printf(format, value);
}

void print(const char* format, double value) {
    printf(format, value);
}

void setValueInSymbolTable(const char* id, double value) {
    std::string name(id);
    symbolTable[name] = value;
}

double getValueFromSymbolTable(const char* id) {
    std::string name(id);
    if (symbolTable.find(name) != symbolTable.end()) {
        return symbolTable[name];
    }
    return 0; // This is the default value for an identifier.
}
