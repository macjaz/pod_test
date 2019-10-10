// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: com/taikang/im/protobuf/message/VoiceMessage.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#import <SakuraKit/VoiceMessage.pbobjc.h>

#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#import "VoiceMessage.pbobjc.h"

#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - VoiceMessageRoot

@implementation VoiceMessageRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - VoiceMessageRoot_FileDescriptor

static GPBFileDescriptor *VoiceMessageRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - VoiceMessage

@implementation VoiceMessage

@dynamic mediaId;
@dynamic duration;
@dynamic size;
@dynamic type;

typedef struct VoiceMessage__storage_ {
  uint32_t _has_storage_[1];
  int32_t duration;
  NSString *mediaId;
  NSString *type;
  int64_t size;
} VoiceMessage__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "mediaId",
        .dataTypeSpecific.className = NULL,
        .number = VoiceMessage_FieldNumber_MediaId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(VoiceMessage__storage_, mediaId),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldTextFormatNameCustom),
        .dataType = GPBDataTypeString,
      },
      {
        .name = "duration",
        .dataTypeSpecific.className = NULL,
        .number = VoiceMessage_FieldNumber_Duration,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(VoiceMessage__storage_, duration),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
      },
      {
        .name = "size",
        .dataTypeSpecific.className = NULL,
        .number = VoiceMessage_FieldNumber_Size,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(VoiceMessage__storage_, size),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
      },
      {
        .name = "type",
        .dataTypeSpecific.className = NULL,
        .number = VoiceMessage_FieldNumber_Type,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(VoiceMessage__storage_, type),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[VoiceMessage class]
                                     rootClass:[VoiceMessageRoot class]
                                          file:VoiceMessageRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(VoiceMessage__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    static const char *extraTextFormatInfo =
        "\001\001\007\000";
    [localDescriptor setupExtraTextInfo:extraTextFormatInfo];
#endif  // !GPBOBJC_SKIP_MESSAGE_TEXTFORMAT_EXTRAS
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
