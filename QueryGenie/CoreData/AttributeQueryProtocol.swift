//
//  AttributeQueryProtocol.swift
//  ZRCoreData
//
//  Copyright (c) 2016 App-Order, LLC. All rights reserved.
//

import Foundation
import CoreData

// TODO: Document

public protocol AttributeQueryProtocol: CoreDataQueryable {
    
    var returnsDistinctResults: Bool { get set }
    var propertiesToFetch: [String] { get set }
    
}

// MARK: -

extension AttributeQueryProtocol {
    
    public func distinct() -> Self {
        var clone = self
        clone.returnsDistinctResults = true
        
        return self
    }
    
}

/*
 *  MARK: - GenericQueryable
 */

extension AttributeQueryProtocol {
    
    public func objects() -> AnyCollection<Self.Element> {
        do {
            let fetchRequest = self.toFetchRequest() as NSFetchRequest<NSDictionary>
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            
            var results: [Self.Element] = []
            
            let dicts: [NSDictionary]
            
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                dicts = try fetchRequest.execute()
            }
            else {
                dicts = try self.context.fetch(fetchRequest)
            }
            
            try dicts.forEach {
                guard $0.count == 1, let value = $0.allValues.first as? Self.Element else {
                    throw Error.unexpectedValue($0)
                }
                
                results.append(value)
            }
            
            return AnyCollection(results)
        }
        catch {
            return AnyCollection<Self.Element>([])
        }
    }
    
}

extension AttributeQueryProtocol where Self.Element: NSDictionary {
    
    public func objects() -> AnyCollection<Self.Element> {
        do {
            return try AnyCollection(self.context.fetch(self.toFetchRequest() as NSFetchRequest<Self.Element>))
        }
        catch {
            return AnyCollection<Self.Element>([])
        }
    }
    
}


// MARK: - CoreDataQueryable

extension AttributeQueryProtocol where Self.Element: NSDictionary {
    
    public final func toFetchRequest<ResultType: NSFetchRequestResult>() -> NSFetchRequest<ResultType> {
        let fetchRequest = NSFetchRequest<ResultType>()
        
        fetchRequest.entity = self.entityDescription
        
        fetchRequest.fetchOffset = self.offset
        fetchRequest.fetchLimit = self.limit
        fetchRequest.fetchBatchSize = (self.limit > 0 && self.batchSize > self.limit ? 0 : self.batchSize)
        
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = self.sortDescriptors
        
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = self.returnsDistinctResults
        fetchRequest.propertiesToFetch = self.propertiesToFetch
                
        return fetchRequest
    }
    
}

