//
//  NSObject+LXIntrospection.m
//
//  Created by 从今以后 on 15/11/16.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "NSObject+LXIntrospection.h"

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic ignored "-Wcstring-format-directive"

#define LXFree(ptr) if (ptr != NULL) { free(ptr); }

#define LXLog(format, ...) \
printf("%s[%d] %s\n%s\n", \
(strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1, \
__LINE__, \
__FUNCTION__, \
[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

#pragma mark - 格式化辅助函数 -

static NSString *__LXTypeStringForTypeEncode(const char *typeEncode)
{
	// 普通类型
	switch (typeEncode[0]) {
		case 'c': return @"char";
		case 'C': return @"unsigned char";
		case 's': return @"short";
		case 'S': return @"unichar";
		case 'i': return @"int";
		case 'I': return @"unsigned int";
		case 'q': return @"long";
		case 'Q': return @"unsigned long";
		case 'f': return @"float";
		case 'd': return @"double";
		case 'D': return @"long double";
		case 'B': return @"bool";
		case 'v': return @"void";
		case '*': return @"char *";
		case '#': return @"Class";
		case ':': return @"SEL";
	}

	// @ 开头表示对象
	if (typeEncode[0] == '@') {
		// 单个 @ 表示 id 类型
		if (strlen(typeEncode) == 1) return @"id";

		// @? 表示 block 类型，无法确定具体类型
		if (!strcmp(typeEncode, "@?")) return @"Block";

		// 某种对象类型，类似 @"NSString" 这种格式
		NSString *typeEncodeStr = [NSString stringWithUTF8String:typeEncode];
		NSString *typeStr = [typeEncodeStr substringWithRange:NSMakeRange(2, typeEncodeStr.length - 3)];
		return [typeStr stringByAppendingString:@" *"];
	}

	// { 开头表示结构体，类似 {CGPoint=dd} 这种格式，如果是结构体二级指针，例如 CGPoint **，格式为 {CGPoint}
	if (typeEncode[0] == '{') {
		NSString *typeEncodeStr = [NSString stringWithUTF8String:typeEncode];
		NSUInteger equalSignloc = [typeEncodeStr rangeOfString:@"="].location;
		NSRange typeRange = { 1,  equalSignloc == NSNotFound ? typeEncodeStr.length - 2:  equalSignloc - 1 };
		return [typeEncodeStr substringWithRange:typeRange];
	}

	// ^ 开头表示指针类型，例如 ^i 表示 int *
	if (typeEncode[0] == '^') {
		// ^? 表示函数指针类型，但是无法确定具体类型
		if (typeEncode[1] == '?') return @"FunctionPointer";

		// 进一步确定指针类型
		NSString *subtypeEncode = [[NSString stringWithUTF8String:typeEncode] substringFromIndex:1];
		NSString *subtypeStr = __LXTypeStringForTypeEncode(subtypeEncode.UTF8String);
		return [NSString stringWithFormat:@"%@%@*",
				subtypeStr, [subtypeStr hasSuffix:@"*"] ? @"" : @" "];
	}

	// [ 开头表示数组类型，例如 [3i] 表示 int[3]
	if (typeEncode[0] == '[') {
		NSString *typeEncodeStr = [NSString stringWithUTF8String:typeEncode];
		NSRange digitRange = [typeEncodeStr rangeOfString:@"\\d+" options:NSRegularExpressionSearch];
		NSString *digitStr = [typeEncodeStr substringWithRange:digitRange];
		NSRange typeRange = { digitRange.location + digitRange.length, typeEncodeStr.length - digitRange.length - 2 };
		NSString *subtypeEncodeStr = [typeEncodeStr substringWithRange:typeRange];

		NSString *subtypeStr = __LXTypeStringForTypeEncode(subtypeEncodeStr.UTF8String);
		NSRange range = [subtypeStr rangeOfString:@"["];
		if (range.location != NSNotFound) {
			// 例如，解析后还是个数组，类型为 int[3]，外层数组容量为 2，则拼接格式为 int [2][3]
			NSString *typeStr = [subtypeStr substringToIndex:range.location];
			NSString *otherStr = [subtypeStr substringFromIndex:range.location];
			return [NSString stringWithFormat:@"%@[%@]%@", typeStr, digitStr, otherStr];
		} else {
			return [NSString stringWithFormat:@"%@[%@]", subtypeStr, digitStr];
		}
	}

	// 某些特殊限定符
	NSString *qualifiers = nil;
	{
		switch (typeEncode[0]) {
			case 'r': qualifiers = @"const";  break;
			case 'n': qualifiers = @"in";     break;
			case 'N': qualifiers = @"inout";  break;
			case 'o': qualifiers = @"out";    break;
			case 'O': qualifiers = @"bycopy"; break;
			case 'R': qualifiers = @"byref";  break;
			case 'V': qualifiers = @"oneway"; break;
		}
		if (qualifiers) {
			NSString *subtypeEncodeStr = [[NSString stringWithUTF8String:typeEncode] substringFromIndex:1];
			return [NSString stringWithFormat:@"%@ %@",
					qualifiers, __LXTypeStringForTypeEncode(subtypeEncodeStr.UTF8String)];
		}
	}

	if (!strcmp(typeEncode, @encode(va_list))) return @"va_list";

	return @"?"; // 无法确定
}

static NSString *__LXProperyDescription(objc_property_t prop)
{
	char *atomic = "atomic";
	char *policy = "assign";
	char getter[100] = {};
	char setter[100] = {};
	char *readwrite = "";
	NSString *propertyType = nil;
	const char *propertyName = property_getName(prop);

	uint attrCount;
	objc_property_attribute_t *attrs = property_copyAttributeList(prop, &attrCount);
	for (uint idx = 0; idx < attrCount; ++idx) {
		const char *name  = attrs[idx].name;
		const char *value = attrs[idx].value;
		switch (name[0]) {
			case 'N': atomic = "nonatomic"; break;
			case '&': policy = "strong"; break;
			case 'C': policy = "copy"; break;
			case 'W': policy = "weak"; break;
			case 'R': readwrite = ", readonly"; break;
			case 'G': strcpy(getter, ", getter="); strcat(getter, value); break;
			case 'S': strcpy(setter, ", setter="); strcat(setter, value); break;
			case 'T': propertyType = __LXTypeStringForTypeEncode(value); break;
		}
	}
	LXFree(attrs);

	return [NSString stringWithFormat:@"@property (%s, %s%s%s%s) %@%@%s",
			atomic,
			policy,
			setter,
			getter,
			readwrite,
			propertyType,
			[propertyType hasSuffix:@"*"] ? @"": @" ",
			propertyName];
}

static NSArray<NSString *> *__LXProtocolMethodDescriptionList(Protocol *proto, BOOL isRequiredMethod, BOOL isInstanceMethod)
{
	uint outCount;
	struct objc_method_description *methods =
	protocol_copyMethodDescriptionList(proto, isRequiredMethod, isInstanceMethod,  &outCount);

	NSMutableArray *descriptionList = [NSMutableArray arrayWithCapacity:outCount];

	for (uint i = 0; i < outCount; ++i) {

		NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methods[i].types];

		NSString *methodDescription = [NSString stringWithFormat:@"%@ (%@)%s",
									   isInstanceMethod ? @"-" : @"+",
									   __LXTypeStringForTypeEncode(methodSignature.methodReturnType),
									   sel_getName(methods[i].name)];

		NSMutableArray *selParts = [[methodDescription componentsSeparatedByString:@":"] mutableCopy];
		{
			if (selParts.count > 1) [selParts removeLastObject]; // 移除末尾的 @""

			NSUInteger args = methodSignature.numberOfArguments;
			for (NSUInteger idx = 2; idx < args; ++idx) {
				const char *argumentType = [methodSignature getArgumentTypeAtIndex:idx];
				selParts[idx - 2] = [NSString stringWithFormat:@"%@:(%@)arg%lu",
									 selParts[idx - 2],
									 __LXTypeStringForTypeEncode(argumentType),
									 idx - 2];
			}
		}

		selParts.count > 1 ?
		[descriptionList addObject:[selParts componentsJoinedByString:@" "]] :
		[descriptionList addObject:selParts[0]];
	}

	LXFree(methods);

	return descriptionList;
}

#pragma mark - 查看所有类的类名 -

NSArray<NSString *> *LXClassNameList()
{
	uint outCount;
	Class *classes = objc_copyClassList(&outCount);
	NSMutableArray *classNameList = [NSMutableArray arrayWithCapacity:outCount];
	for (uint i = 0; i < outCount; ++i) {
		[classNameList addObject:NSStringFromClass(classes[i])];
	}
	LXFree(classes);
	return [classNameList sortedArrayUsingSelector:@selector(compare:)];
}

void LXPrintClassNameList()
{
	NSArray *classList = LXClassNameList();
	LXLog(@"总计：%lu\n%@", classList.count, classList);
}

#pragma mark - 查看协议中的方法和属性 -

NSDictionary<NSString *, NSArray<NSString *> *> *LXProtocolDescription(Protocol *proto)
{
	NSArray *requiredMethods = nil;
	{
		NSArray *classMethods    = __LXProtocolMethodDescriptionList(proto, YES, NO);
		NSArray *instanceMethods = __LXProtocolMethodDescriptionList(proto, YES, YES);
		requiredMethods = [classMethods arrayByAddingObjectsFromArray:instanceMethods];
	}

	NSArray *optionalMethods = nil;
	{
		NSArray *classMethods    = __LXProtocolMethodDescriptionList(proto, NO, NO);
		NSArray *instanceMethods = __LXProtocolMethodDescriptionList(proto, NO, YES);
		optionalMethods = [classMethods arrayByAddingObjectsFromArray:instanceMethods];
	}

	uint outCount;
	objc_property_t *properties = protocol_copyPropertyList(proto, &outCount);

	NSMutableArray *propertyDescriptions = [NSMutableArray arrayWithCapacity:outCount];

	for (uint i = 0; i < outCount; ++i) {
		[propertyDescriptions addObject:__LXProperyDescription(properties[i])];
	}

	LXFree(properties);

	NSMutableDictionary *methodsAndProperties = [NSMutableDictionary dictionaryWithCapacity:3];
	{
		if (requiredMethods.count) {
			methodsAndProperties[@"@required"] = requiredMethods;
		}
		if (optionalMethods.count) {
			methodsAndProperties[@"@optional"] = optionalMethods;
		}
		if (propertyDescriptions.count) {
			methodsAndProperties[@"@properties"] = propertyDescriptions;
		}
	}

	return methodsAndProperties;
}

void LXPrintDescriptionForProtocol(Protocol *proto)
{
	LXLog(@"%s\n%@", protocol_getName(proto), LXProtocolDescription(proto));
}

#pragma mark -

@implementation NSObject (LXIntrospection)

#pragma mark - 查看实例变量和属性 -

+ (NSArray<NSString *> *)lx_propertyDescriptionList
{
	NSMutableArray *result = [NSMutableArray new];

	for (Class class = self; class != Nil; class = class_getSuperclass(class)) {
		uint outCount;
		objc_property_t *properties = class_copyPropertyList(class, &outCount);
		for (uint i = 0; i < outCount; ++i) {
			[result addObject:__LXProperyDescription(properties[i])];
		}
		LXFree(properties);
	}

	return result;
}

+ (void)lx_printPropertyDescriptionList
{
	LXLog(@"%s\n%@", class_getName(self), [self lx_propertyDescriptionList]);
}

+ (NSArray<NSString *> *)lx_ivarDescriptionList
{
	NSMutableArray *ivarList = [NSMutableArray new];

	for (Class class = self; class != Nil; class = class_getSuperclass(class)) {

		uint outCount;
		Ivar *ivars = class_copyIvarList(class, &outCount);

		for (uint i = 0; i < outCount; ++i) {
			NSString *ivarType = __LXTypeStringForTypeEncode(ivar_getTypeEncoding(ivars[i]));

			if ([ivarType hasSuffix:@"]"]) { // 数组类型，类似 int *[233] 这种形式

				// 判断 [ 前是否是 *，若是则变量名和 * 间不空格，否则变量名和类型之间要空格
				NSRange bracketRange  = [ivarType rangeOfString:@"["];
				NSRange asteriskRange = { bracketRange.location - 1, 1 };
				asteriskRange = [ivarType rangeOfString:@"*" options:0 range:asteriskRange];

				NSString *ivarName = [NSString stringWithFormat:@"%@%s",
									  asteriskRange.location == NSNotFound ? @" " : @"",
									  ivar_getName(ivars[i])];

				NSMutableString *ivarDesc = [ivarType mutableCopy];
				[ivarDesc insertString:ivarName atIndex:bracketRange.location];
				[ivarList addObject:ivarDesc];

			} else { // 普通类型，形如 int * 或者 int
				NSString *ivarDesc = [NSString stringWithFormat:@"%@%@%s",
									  ivarType,
									  [ivarType hasSuffix:@"*"] ? @"" : @" ",
									  ivar_getName(ivars[i])];
				[ivarList addObject:ivarDesc];
			}
		}

		LXFree(ivars);
	}

	return ivarList;
}

+ (void)lx_printIvarDescriptionList
{
	LXLog(@"%s\n%@", class_getName(self), [self lx_ivarDescriptionList]);
}

#pragma mark - 查看方法 -

static NSArray<NSString *> *__LXMethodDescriptionListForClass(Class cls)
{
	NSMutableArray *result = [NSMutableArray new];

	for (Class class = cls; class != Nil; class = class_getSuperclass(class)) {

		uint outCount;
		Method *methods = class_copyMethodList(class, &outCount);

		NSString *methodType = class_isMetaClass(class) ? @"+" : @"-";


		for (uint i = 0; i < outCount; ++i) {

			NSString *methodDescription = nil;
			{
				char *returnType = method_copyReturnType(methods[i]);
				methodDescription = [NSString stringWithFormat:@"%@ (%@)%s",
									 methodType,
									 __LXTypeStringForTypeEncode(returnType),
									 sel_getName(method_getName(methods[i]))];
				LXFree(returnType);
			}

			NSMutableArray *selParts = [[methodDescription componentsSeparatedByString:@":"] mutableCopy];
			{
				if (selParts.count > 1) [selParts removeLastObject]; // 移除末尾的 @""

				uint args = method_getNumberOfArguments(methods[i]);
				for (uint idx = 2; idx < args; ++idx) {
					char *argumentType = method_copyArgumentType(methods[i], idx);
					selParts[idx - 2] = [NSString stringWithFormat:@"%@:(%@)arg%d",
										 selParts[idx - 2],
										 __LXTypeStringForTypeEncode(argumentType),
										 idx - 2];
					LXFree(argumentType);
				}
			}

			selParts.count > 1 ?
			[result addObject:[selParts componentsJoinedByString:@" "]] :
			[result addObject:selParts[0]];
		}

		LXFree(methods);
	}

	return result;
}

+ (NSArray<NSString *> *)lx_classMethodDescriptionList
{
	return __LXMethodDescriptionListForClass(object_getClass(self));
}

+ (void)lx_printClassMethodDescriptionList
{
	LXLog(@"%s\n%@", class_getName(self), [self lx_classMethodDescriptionList]);
}

+ (NSArray<NSString *> *)lx_instanceMethodDescriptionList
{
	return __LXMethodDescriptionListForClass(self);
}

+ (void)lx_printInstanceMethodDescriptionList
{
	LXLog(@"%s\n%@", class_getName(self), [self lx_instanceMethodDescriptionList]);
}

#pragma mark - 查看采纳的协议 -

+ (NSArray<NSString *> *)lx_adoptedProtocolDescriptionList
{
	uint outCount;
	Protocol *__unsafe_unretained *protocols = class_copyProtocolList(self, &outCount);

	NSMutableArray *result = [NSMutableArray arrayWithCapacity:outCount];

	for (uint i = 0; i < outCount; ++i) {

		uint adoptedCount;
		Protocol *__unsafe_unretained *adotedProtocols =
		protocol_copyProtocolList(protocols[i], &adoptedCount);

		NSMutableArray *adoptedProtocolNames = [NSMutableArray arrayWithCapacity:adoptedCount];

		for (uint idx = 0; idx < adoptedCount; ++idx) {
			[adoptedProtocolNames addObject:
			 [NSString stringWithUTF8String:protocol_getName(adotedProtocols[idx])]];
		}

		LXFree(adotedProtocols);

		NSMutableString *protocolDescription =
		[NSMutableString stringWithUTF8String:protocol_getName(protocols[i])];

		if (adoptedProtocolNames.count) {
			[protocolDescription appendFormat:@" <%@>",
			 [adoptedProtocolNames componentsJoinedByString:@", "]];
		}

		[result addObject:protocolDescription];
	}

	LXFree(protocols);

	return result;
}

+ (void)lx_printAdoptedProtocolDescriptionList
{
	LXLog(@"%s\n%@", class_getName(self), [self lx_adoptedProtocolDescriptionList]);
}

#pragma mark - 查看继承层级关系 -

+ (NSString *)lx_inheritanceTree
{
	NSMutableArray *classNames = [NSMutableArray new];
	{
		Class superClass = self;
		do {
			[classNames addObject:[NSString stringWithFormat:@"• %s", class_getName(superClass)]];
		} while ((superClass = class_getSuperclass(superClass)));
	}

	NSMutableString *result = [NSMutableString new];
	{
		NSUInteger count = classNames.count;
		[classNames enumerateObjectsWithOptions:NSEnumerationReverse
									 usingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
										 NSMutableString *className = [obj mutableCopy];
										 for (NSUInteger i = 0; count - 1 - idx > i; ++i) {
											 [className insertString:@" " atIndex:0];
										 }
										 [result appendFormat:@"\n%@", className];
									 }];
	}

	return result;
}

+ (void)lx_printInheritanceTree
{
	LXLog(@"%s%@", class_getName(self), [self lx_inheritanceTree]);
}

#pragma mark - 获取实例变量名和属性名数组 -

+ (NSArray<NSString *> *)lx_ivarNameList
{
    NSMutableArray *ivarNameList = [NSMutableArray new];

    for (Class class = self; class != Nil; class = class_getSuperclass(class)) {
        uint outCount = 0;
        Ivar *ivars = class_copyIvarList(class, &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [ivarNameList addObject:@(ivar_getName(ivars[i]))];
        }
        LXFree(ivars);
    }

	return ivarNameList;
}

+ (NSArray<NSString *> *)lx_propertyNameList
{
    NSMutableArray *propertyNameList = [NSMutableArray new];

    for (Class class = self; class != Nil; class = class_getSuperclass(class)) {
        uint outCount = 0;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (uint i = 0; i < outCount; ++i) {
            [propertyNameList addObject:@(property_getName(properties[i]))];
        }
        LXFree(properties);
    }

	return propertyNameList;
}

@end

NS_ASSUME_NONNULL_END
