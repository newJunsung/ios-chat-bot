//
//  GPTMessage.swift
//  ChatBot
//
//  Created by 김준성 on 1/2/24.
//

import Foundation

extension Model {
    struct GPTMessage: GPTMessagable, Identifiable {
        let id: UUID = UUID()
        let role: GPTMessageRole
        let content: String?
        let name: String?
        let toolCalls: [GPTToolCall]?
        let toolCallID: String?
        
        init(role: GPTMessageRole, content: String?, name: String?, toolCalls: [GPTToolCall]?, toolCallID: String?) {
            self.role = role
            self.content = content
            self.name = name
            self.toolCalls = toolCalls
            self.toolCallID = toolCallID
        }
        
        init(requestMessage: Model.GPTMessage) {
            self.role = requestMessage.role
            self.content = requestMessage.content
            self.name = requestMessage.name
            self.toolCalls = requestMessage.toolCalls
            self.toolCallID = requestMessage.toolCallID
        }
        
        func asRequestMessage() -> Model.GPTMessage { self }
    }
}

extension Model.GPTMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
        case toolCalls = "tool_calls"
        case toolCallID = "tool_call_id"
    }
}

extension Model.GPTMessage: Hashable {
    static func == (lhs: Model.GPTMessage, rhs: Model.GPTMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Model {
    struct GPTToolCall: Codable {
        var id: String
        var type: String
        var function: Function
    }
}

extension Model.GPTToolCall {
    struct Function: Codable {
        var name: String
        var arguments: String
    }
}
