//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//  Modified by Jiazheng Yu

import Foundation

//For this assignment, I used the Shunting-yard algorithm
//Shunting-yard algorithm takes a string of charactors, and re-order them in a specified rule, then calculate them
//I think this algorithm is suitable for a complex expression calculation
//I think one of the advantage of this algorithm is it could cover all the operators, even I just created one
//Every operator has their precedence and associativity, with these two priorities, the algorithm could work well

//At the begining of the program, I set a few arrays include operators with different types
//So when I want to konw an operator, I could reuse these arrays to check it
let allOperations = ["+", "-", "x", "/", "%",  "(", ")"]
let ops = ["+", "-", "x", "/", "%"]
let posNegOps = ["+", "-"]
let leftAssociativity = ["-", "/", "%", "x", "+"]
let higherPrecedence = ["x", "/", "%"]
let lowerPrecedence = ["+", "-"]

//function for check the properties of two operators
func checkOperation(first: String, second: String) -> Bool {
    var preFirst = 0
    var preSecond = 0
    if higherPrecedence.contains(first) {
        preFirst = 1
    }
    if higherPrecedence.contains(second) {
        preSecond = 1
    }
    let result: Bool = (preSecond > preFirst) || ((preSecond == preFirst) && leftAssociativity.contains(second))
    return result
}

//function for calculating
func calculateFunc(first: Int, second: Int, opera: String) -> String {
    var result = ""
    switch opera {
    case "+":
        result = String(first + second)
        break
    case "-":
        result = String(first - second)
        break
    case "x":
        result = String(first * second)
        break
    case "/":
        if second == 0 {
            print("Invalid expression, 0 divided.")
        }
        result = String(first / second)
        break
    case "%":
        if second == 0 {
            print("Invalid expression, 0 divided.")
        }
        result = String(first % second)
        break
    default:
        break
    }
    return result
}


var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program

//Combine numbers, for example, ["3", "4" ....] will be combined to ["34" ...]
var outputArray1: [String] = []
var theNum = ""
for i in 0..<args.count {
    if allOperations.contains(args[i]) {
        if !theNum.isEmpty {
            outputArray1.append(theNum)
            theNum = ""
        }
        outputArray1.append(args[i])
    } else {
        theNum += args[i]
    }
}
if !theNum.isEmpty {
    outputArray1.append(theNum)
}

args = outputArray1
//

//Check positive and negative number
var outputArray2: [String] = []
var theNevPos = ""
var isNev = false
for i in 0..<args.count {
    if posNegOps.contains(args[i]) && allOperations.contains(args[i-1]) {
        theNevPos += args[i]
    } else if Int(args[i]) != nil {
        if theNevPos.isEmpty {
            outputArray2.append(args[i])
        } else {
            for (_, char) in theNevPos.enumerated() {
                if char == "-" {
                    isNev = !isNev
                }
            }
            if isNev {
                args[i] = "-" + args[i]
            }
            outputArray2.append(args[i])
            isNev = true
        }
    } else {
        outputArray2.append(args[i])
    }
}

args = outputArray2
//

//Re-order with Shunting-yard algorithm
//Here, I created two arrays, one for output, one for store operators
//If a token is a number, put it into the output array
//If it's an operator, checke it's priority and the first operator in operators array
//Follow a few rules, operators will be put into operators array or output array
var outputArray3: [String] = []
var operations: [String] = []

for i in 0..<args.count {
    if Int(args[i]) != nil {
        outputArray3.append(args[i])
    } else if ops.contains(args[i]) {
        if operations.isEmpty {
            operations.append(args[i])
        } else {
            while !operations.isEmpty
                && checkOperation(first: args[i], second: operations[0])
                && operations[0] != "(" {
                        outputArray3.append(operations[0])
                        operations.removeFirst()
            }
            operations.insert(args[i], at: 0)
        }
    } else if args[i] == "(" {
        operations.insert(args[i], at: 0)
    } else if args[i] == ")" {
        while operations[0] != "(" {
            outputArray3.append(operations[0])
            operations.removeFirst()
        }
        operations.removeFirst()
    }
}
//if there are no more tokens to read
if !operations.isEmpty {
    for i in 0..<operations.count {
        outputArray3.append(operations[i])
    }
}

args = outputArray3
//Now the args array is in the Shunting-yard order

//Calculate the array
while args.count > 1 {
    for i in 0..<args.count {
        if Int(args[i]) == nil {
            let firstVal = (args[i-2] as NSString).integerValue
            let secondVal = (args[i-1] as NSString).integerValue
            let resultVal = calculateFunc(first: firstVal, second: secondVal, opera: args[i])
            //remove the two numbers and the operators, insert the result number to instead them
            args.remove(at: i-2)
            args.remove(at: i-2)
            args.remove(at: i-2)
            args.insert(resultVal, at: i-2)
            break
        }
    }
}
//The final args array will contains only one value which is the final result

print(Int(args[0])!)
