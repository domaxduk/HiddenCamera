//
//  ShapeData.swift
//  Runner
//
//  Created by Hien Nguyen on 19/4/24.
//

import Foundation

// MARK: - Shape
struct ShapeData<T> {
    var shape: [Int]
    var data: [T]
    
    subscript(indices: Int...) -> T? {
        guard indices.count == shape.count else {
            print("Invalid number of indices provided")
            return nil
        }
        var index = 0
        var stride = 1
        for (dimensionIndex, dimensionSize) in zip(indices, shape).reversed() {
            if dimensionIndex >= dimensionSize || dimensionIndex < 0 {
                print("Index out of range")
                return nil
            }
            index += dimensionIndex * stride
            stride *= dimensionSize
        }
        
        return data[index]
    }
    
    subscript(index: Int) -> [T]? {
        guard index < shape[0] else {
            print("Index out of range for accessing row")
            return nil
        }
        let rowStart = index * shape[1] * shape[2]
        let rowEnd = (index + 1) * shape[1] * shape[2]
        return Array(data[rowStart..<rowEnd])
    }
    
    subscript(row: Int, column: Int) -> T? {
        let index = row * shape[2] + column
        guard index < shape[1] * shape[2] else {
            print("Index out of range for accessing column")
            return nil
        }
        return data[row * shape[1] * shape[2] + column]
    }
    
    // get total row count
    func getRowCount() -> Int? {
        return shape.count > 1 ? shape[1] : nil
    }
    
    // get total columnn count
    func getColCount() -> Int? {
        return shape.count > 1 ? shape[2] : nil
    }
}
