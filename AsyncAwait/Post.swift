//
//  Post.swift
//  AsyncAwait
//
//  Created by Grigor Aghabalyan on 14.06.22.
//

import Foundation

struct Post: Codable {
    
    let id: Int
    let title: String
    let body: String
    
    var comments: [Comment] = []
    
    mutating func addComments(comments: [Comment]) {
        self.comments.append(contentsOf: comments)
    }
    
    private enum CodingKeys : String, CodingKey {
           case id = "id"
           case title = "title"
           case body = "body"
       }
}
