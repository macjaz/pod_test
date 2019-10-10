// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: com/taikang/im/protobuf/ChatMessageReq.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class MessageBody;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ChatMessageReqRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface ChatMessageReqRoot : GPBRootObject
@end

#pragma mark - ChatMessageReq

typedef GPB_ENUM(ChatMessageReq_FieldNumber) {
  ChatMessageReq_FieldNumber_MessageId = 1,
  ChatMessageReq_FieldNumber_From = 2,
  ChatMessageReq_FieldNumber_To = 3,
  ChatMessageReq_FieldNumber_DeviceType = 4,
  ChatMessageReq_FieldNumber_Body = 5,
  ChatMessageReq_FieldNumber_SourceLabel = 6,
  ChatMessageReq_FieldNumber_TargetLabel = 7,
  ChatMessageReq_FieldNumber_Domain = 8,
};

@interface ChatMessageReq : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *messageId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *from;

@property(nonatomic, readwrite, copy, null_resettable) NSString *to;

@property(nonatomic, readwrite) int32_t deviceType;

@property(nonatomic, readwrite, strong, null_resettable) MessageBody *body;
/** Test to see if @c body has been set. */
@property(nonatomic, readwrite) BOOL hasBody;

@property(nonatomic, readwrite, copy, null_resettable) NSString *sourceLabel;

@property(nonatomic, readwrite, copy, null_resettable) NSString *targetLabel;

@property(nonatomic, readwrite, copy, null_resettable) NSString *domain;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
