//
//  LXMacro.h
//
//  Created by 从今以后 on 15/10/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#pragma mark - 安全调用闭包 -

///------------
/// @name 便捷宏
///------------

#define LXFree(ptr) if (ptr != NULL) { free(ptr); }
#define LX_BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); }

#pragma mark - 忽略警告 -

///--------------
/// @name 忽略警告
///--------------

#define STRINGIFY(S) #S

#define LX_DIAGNOSTIC_PUSH_IGNORED(warning) \
_Pragma("clang diagnostic push") \
_Pragma(STRINGIFY(clang diagnostic ignored #warning))

#define LX_DIAGNOSTIC_POP _Pragma("clang diagnostic pop")

#pragma mark - 日志打印 -

///--------------
/// @name 日志打印
///--------------

#ifdef DEBUG

#define LXLog(format, ...) \
LX_DIAGNOSTIC_PUSH_IGNORED(-Wformat-security) \
printf("%s[%d] %s %s\n", \
(strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1, \
__LINE__, \
__FUNCTION__, \
[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]) \
LX_DIAGNOSTIC_POP

#define LXLogRect(rect)           LXLog(@"%s => %@", #rect, NSStringFromCGRect(rect))
#define LXLogSize(size)           LXLog(@"%s => %@", #size, NSStringFromCGSize(size))
#define LXLogPoint(point)         LXLog(@"%s => %@", #point, NSStringFromCGPoint(point))
#define LXLogRange(range)         LXLog(@"%s => %@", #range, NSStringFromRange(range))
#define LXLogInsets(insets)       LXLog(@"%s => %@", #insets, NSStringFromUIEdgeInsets(insets))
#define LXLogIndexPath(indexPath) LXLog(@"%s => %lu - %lu", #indexPath, [indexPath indexAtPosition:0], [indexPath indexAtPosition:1])

#pragma mark - 计算代码执行耗时 -

///---------------------
/// @name 计算代码执行耗时
///--------------------

#define LX_BENCHMARKING_BEGIN CFTimeInterval begin = CACurrentMediaTime();
#define LX_BENCHMARKING_END   CFTimeInterval end   = CACurrentMediaTime(); printf("运行时间: %g 秒\n", end - begin);

#pragma mark -

#else

#define LXLog(format, ...)
#define LXLogRect(rect)
#define LXLogSize(size)
#define LXLogPoint(point)
#define LXLogRange(range)
#define LXLogInsets(insets)
#define LXLogIndexPath(indexPath)

#define LX_BENCHMARKING_BEGIN
#define LX_BENCHMARKING_END

#endif

#pragma mark - 单例 -

///-----------
/// @name 单例
///-----------

/// 使用 dispatch_once 函数实现，重写了 +allocWithZone:。
#define LX_SINGLETON_INTERFACE(methodName) + (instancetype)methodName;
#define LX_SINGLETON_IMPLEMENTTATION(methodName) \
\
+ (instancetype)methodName \
{ \
    static id sharedInstance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance = [[super allocWithZone:NULL] init]; \
    }); \
    return sharedInstance; \
} \
\
+ (instancetype)allocWithZone:(__unused struct _NSZone *)zone \
{ \
    return [self methodName]; \
}
