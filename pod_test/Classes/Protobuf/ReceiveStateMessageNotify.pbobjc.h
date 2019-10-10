// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: com/taikang/im/protobuf/ReceiveStateMessageNotify.proto

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

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ReceiveStateMessageNotifyRoot

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
@interface ReceiveStateMessageNotifyRoot : GPBRootObject
@end

#pragma mark - ReceiveStateMessageNotify

typedef GPB_ENUM(ReceiveStateMessageNotify_FieldNumber) {
  ReceiveStateMessageNotify_FieldNumber_MessageId = 1,
  ReceiveStateMessageNotify_FieldNumber_SessionId = 2,
  ReceiveStateMessageNotify_FieldNumber_SessionType = 3,
  ReceiveStateMessageNotify_FieldNumber_From = 4,
  ReceiveStateMessageNotify_FieldNumber_To = 5,
  ReceiveStateMessageNotify_FieldNumber_DeviceType = 6,
  ReceiveStateMessageNotify_FieldNumber_Domain = 7,
  ReceiveStateMessageNotify_FieldNumber_EventType = 8,
  ReceiveStateMessageNotify_FieldNumber_EventTargetId = 9,
};

@interface ReceiveStateMessageNotify : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *messageId;

@property(nonatomic, readwrite, copy, null_resettable) NSString *sessionId;

/** CHAT, GROUP, SYSTEM */
@property(nonatomic, readwrite, copy, null_resettable) NSString *sessionType;

@property(nonatomic, readwrite, copy, null_resettable) NSString *from;

@property(nonatomic, readwrite, copy, null_resettable) NSString *to;

@property(nonatomic, readwrite) int32_t deviceType;

@property(nonatomic, readwrite, copy, null_resettable) NSString *domain;

/** 1 delivered, 2 displayed, 4 accepted */
@property(nonatomic, readwrite) int32_t eventType;

/** target message id */
@property(nonatomic, readwrite, copy, null_resettable) NSString *eventTargetId;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
