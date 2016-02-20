//
//  NSNotificationCenter+LXExtension.m
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSNotificationCenter+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSNotificationCenter (LXExtension)

+ (void)lx_observeKeyboardStateWithObserver:(id)observer
							selectorForShow:(SEL)aSelectorForShow
							selectorForHide:(SEL)aSelectorForHide
{
	[[self defaultCenter] addObserver:observer
							 selector:aSelectorForShow
								 name:UIKeyboardWillShowNotification
							   object:nil];

	[[self defaultCenter] addObserver:observer
							 selector:aSelectorForHide
								 name:UIKeyboardWillHideNotification
							   object:nil];
}

+ (id<NSObject>)lx_observeKeyboardFrameChangeWithBlock:(void (^)(NSNotification *note))block
{
	return [[self defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
											 object:nil
											  queue:[NSOperationQueue mainQueue]
										 usingBlock:block];
}

+ (id<NSObject>)lx_observeContentSizeCategoryChangeWithBlock:(void (^)(NSNotification *note))block
{
	return [[self defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
											 object:nil
											  queue:[NSOperationQueue mainQueue]
										 usingBlock:block];
}

@end

NS_ASSUME_NONNULL_END
