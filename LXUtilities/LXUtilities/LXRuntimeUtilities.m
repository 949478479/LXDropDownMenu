//
//  LXRuntimeUtilities.m
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXRuntimeUtilities.h"

NS_ASSUME_NONNULL_BEGIN

void LXMethodSwizzling(Class cls, SEL originalSel, SEL swizzledSel)
{
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);

    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);

    const char *swizzledTypes = method_getTypeEncoding(swizzledMethod);

    BOOL didAddMethod = class_addMethod(cls, originalSel, swizzledIMP, swizzledTypes);

    if (didAddMethod) {
        method_setImplementation(swizzledMethod, originalIMP);
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

NSArray<NSString *> *lx_protocol_propertyList(Protocol *protocol)
{
    NSMutableArray *propertyList = [NSMutableArray new];
    {
        uint outCount = 0;
        objc_property_t *properties = protocol_copyPropertyList(protocol, &outCount);
        for (uint i = 0; i< outCount; ++i) {
            [propertyList addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
        }
		if (properties) free(properties);
    }
    return propertyList;
}

NS_ASSUME_NONNULL_END
