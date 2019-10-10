// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: com/taikang/im/protobuf/message/VoiceMessage.proto

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

#pragma mark - VoiceMessageRoot

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
@interface VoiceMessageRoot : GPBRootObject
@end

#pragma mark - VoiceMessage

typedef GPB_ENUM(VoiceMessage_FieldNumber) {
  VoiceMessage_FieldNumber_MediaId = 1,
  VoiceMessage_FieldNumber_Duration = 2,
  VoiceMessage_FieldNumber_Size = 3,
  VoiceMessage_FieldNumber_Type = 4,
};

@interface VoiceMessage : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *mediaId;

/** 时长，以秒为单位 */
@property(nonatomic, readwrite) int32_t duration;

@property(nonatomic, readwrite) int64_t size;

/** amr、wav等 */
@property(nonatomic, readwrite, copy, null_resettable) NSString *type;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
