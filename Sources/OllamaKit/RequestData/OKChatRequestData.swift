//
//  OKChatRequestData.swift
//
//
//  Created by Augustinas Malinauskas on 12/12/2023.
//

import Foundation

/// A structure that encapsulates data for chat requests to the Ollama API.
public struct OKChatRequestData: Sendable {
    public let stream: Bool
    
    /// A string representing the model identifier to be used for the chat session.
    public let model: String
    
    /// An array of ``Message`` instances representing the content to be sent to the Ollama API.
    public let messages: [Message]
    
    /// An optional array of ``OKJSONValue`` representing the tools available for tool calling in the chat.
    public let tools: [OKJSONValue]?

    /// Optional ``OKJSONValue`` representing the JSON schema for the response.
    /// Be sure to also include "return as JSON" in your prompt
    public let format: OKJSONValue?

    /// Optional ``OKCompletionOptions`` providing additional configuration for the chat request.
    public var options: OKCompletionOptions?
    
    public let think: OKJSONValue?
    
    public init(model: String, messages: [Message], tools: [OKJSONValue]? = nil, format: OKJSONValue? = nil, think: OKJSONValue? = nil, stream: Bool = true) {
        self.stream = stream
        self.model = model
        self.messages = messages
        self.tools = tools
        self.format = format
        self.think = think
    }
    
    /// A structure that represents a single message in the chat request.
    public struct Message: Encodable, Sendable {
        /// A ``Role`` value indicating the sender of the message (system, assistant, user).
        public let role: Role
        
        /// A string containing the message's content.
        public let content: String
        
        /// A string containing the tool name
        public let toolName: String?
        
        /// The content of the thinking
        public let thinking: String?
        
        /// An optional array of base64-encoded images.
        public let images: [String]?
        
        public let toolCalls: [ToolCall]?
        
        public init(role: Role, content: String, toolName: String? = nil, thinking: String? = nil, images: [String]? = nil, toolCalls: [ToolCall]? = nil) {
            self.role = role
            self.content = content
            self.toolName = toolName
            self.thinking = thinking
            self.images = images
            self.toolCalls = toolCalls
        }
        
        /// An enumeration that represents the role of the message sender.
        public enum Role: String, Encodable, Sendable {
            /// Indicates the message is from the system.
            case system
            
            /// Indicates the message is from the assistant.
            case assistant
            
            /// Indicates the message is from the user.
            case user
            
            /// Indicates the message is from a tool call.
            case tool
        }
        
        /// A structure that represents a tool call in the response.
        public struct ToolCall: Encodable, Sendable {
            /// An optional ``Function`` structure representing the details of the tool call.
            public let function: Function?
            
            public init(function: Function?) {
                self.function = function
            }
            
            /// A structure that represents the details of a tool call.
            public struct Function: Encodable, Sendable {
                /// The name of the tool being called.
                public let name: String
                
                /// An optional ``OKJSONValue`` representing the arguments passed to the tool.
                public let arguments: OKJSONValue?
                
                public init(name: String, arguments: OKJSONValue?) {
                    self.name = name
                    self.arguments = arguments
                }
            }
        }
    }
}

extension OKChatRequestData: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stream, forKey: .stream)
        try container.encode(model, forKey: .model)
        try container.encode(messages, forKey: .messages)
        try container.encodeIfPresent(tools, forKey: .tools)
        try container.encodeIfPresent(format, forKey: .format)
        try container.encodeIfPresent(think, forKey: .think)
        if let options {
            try options.encode(to: encoder)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case stream, model, messages, tools, format, think
    }
}
