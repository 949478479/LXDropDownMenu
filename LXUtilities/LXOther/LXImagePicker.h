//
//  LXImagePicker.h
//
//  Created by 从今以后 on 15/9/26.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;
@class LXImagePicker;

NS_ASSUME_NONNULL_BEGIN

typedef void (^LXImagePickerCancelHandler)(void);
typedef void (^LXImagePickerActionCancelHandler)(void);
typedef void (^LXImagePickerSourceTypeUnAvailableHandler)(void);
typedef void (^LXImagePickerCompletionHandler)(UIImage *originalImage, UIImage * _Nullable editedImage);

@protocol LXImagePickerDelegate <NSObject>

@required
- (void)imagePicker:(LXImagePicker *)imagePicker
    didFinishPickingOriginalImage:(UIImage *)originalImage
        editedImage:(UIImage *)editedImage;

@optional
- (void)imagePickerDidCancel:(LXImagePicker *)imagePicker;
- (void)imagePickerSourceTypeUnAvailable:(LXImagePicker *)imagePicker;

@end

@interface LXImagePicker : NSObject

/// `ActionSheet` 的标题。
@property (nullable, nonatomic, copy) NSString *title;
/// `ActionSheet` 的标题。
@property (nullable, nonatomic, copy) NSString *message;
/// `ActionSheet` 的取消回调。
@property (nullable, nonatomic, copy) LXImagePickerActionCancelHandler actionCancelHandler;

/// 是否允许编辑照片。
@property (nonatomic) BOOL allowsEditing;

/// 不使用闭包方法时必须设置代理。若设置了代理却使用闭包方法，代理方法会被忽略。
@property (nullable, nonatomic, weak) id<LXImagePickerDelegate> delegate;

///-----------------------
/// @name 弹出 ActionSheet
///-----------------------

/// 弹出选择相册或拍照的 `ActionSheet`，在 `iPad` 设备上会弹出 `ActionAlert`。此方法必须设置代理。
- (void)showActionSheet;

/// 弹出选择相册或拍照的 `ActionSheet`，在 `iPad` 设备上会弹出 `ActionAlert`。此方法无需设置代理。
- (void)showActionSheetWithCompletionHandler:(LXImagePickerCompletionHandler)completionHandler
							   cancelHandler:(nullable LXImagePickerCancelHandler)cancelHandler
						  unAvailableHandler:(nullable LXImagePickerSourceTypeUnAvailableHandler)unAvailableHandler;

///--------------------------------------
/// @name 直接打开 UIImagePickerController
///--------------------------------------

/// 直接打开 `UIImagePickerController`。若成功则返回 `YES`，若来源类型不可用则返回 `NO`。此方法必须设置代理。
- (BOOL)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType;

/// 直接打开 `UIImagePickerController`。若成功则返回 `YES`，若来源类型不可用则返回 `NO`。此方法无需设置代理。
- (BOOL)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
								completionHandler:(LXImagePickerCompletionHandler)completionHandler
									cancelHandler:(nullable LXImagePickerCancelHandler)cancelHandler;
@end

NS_ASSUME_NONNULL_END
