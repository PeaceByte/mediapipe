load("@build_bazel_rules_apple//apple:ios.bzl", "ios_framework")

ios_framework(
    name = "SelfieSegmentation",
    hdrs = [
        "SelfieSegmentation.h"
    ],
    infoplists = ["Info.plist"],
    bundle_id = "org.smart.demo.helloworld.selfiesegmentation",
    families = ["iphone", "ipad"],
    minimum_os_version = "11.0",
    deps = [
        ":SelfieSegmentationLib",
        "@ios_opencv//:OpencvFramework",
    ],
)




objc_library(
    name = "SelfieSegmentationLib",
    srcs = [
        "SelfieSegmentation.mm",
    ],
    hdrs = [
        "SelfieSegmentation.h",
    ],
        copts = [
        "-std=c++17"],
    data = [
        "//mediapipe/graphs/selfie_segmentation:selfie_segmentation_gpu.binarypb",
        "//mediapipe/modules/selfie_segmentation:selfie_segmentation.tflite",
    ],
    sdk_frameworks = [
        "AVFoundation",
       # "CoreGraphics",
       # "CoreMedia",
       # "UIKit",
    ],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
        "//mediapipe/objc:CGImageRefUtils",

    ] + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
             "//mediapipe/graphs/selfie_segmentation:selfie_segmentation_gpu_deps",
        ],
    }),
)


