//
//  LXImagePicker.m
//
//  Created by 从今以后 on 15/9/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIWindow+LXExtension.h"
#import "UIDevice+LXExtension.h"
#import "LXImagePicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nullable, nonatomic, copy) LXImagePickerSourceTypeUnAvailableHandler unAvailableHandler;
@property (nullable, nonatomic, copy) LXImagePickerCompletionHandler completionHandler;
@property (nullable, nonatomic, copy) LXImagePickerCancelHandler cancelHandler;
@end

@implementation LXImagePicker

#pragma mark - 公共方法 -

- (void)showActionSheet
{
	NSParameterAssert(self.delegate != nil);

	[self __showActionSheet];
}

- (void)showActionSheetWithCompletionHandler:(LXImagePickerCompletionHandler)completionHandler
							   cancelHandler:(nullable LXImagePickerCancelHandler)cancelHandler
						  unAvailableHandler:(nullable LXImagePickerSourceTypeUnAvailableHandler)unAvailableHandler
{
	NSParameterAssert(completionHandler != nil);

	self.cancelHandler = cancelHandler;
	self.completionHandler = completionHandler;
	self.unAvailableHandler = unAvailableHandler;

    [self __showActionSheet];
}

- (BOOL)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
	NSParameterAssert(self.delegate != nil);

    return [self __presentImagePickerControllerWithSourceType:sourceType];
}

- (BOOL)presentImagePickerControllerForSourceType:(UIImagePickerControllerSourceType)sourceType
								completionHandler:(LXImagePickerCompletionHandler)completionHandler
									cancelHandler:(nullable LXImagePickerCancelHandler)cancelHandler
{
	NSParameterAssert(completionHandler != nil);

    self.cancelHandler = cancelHandler;
    self.completionHandler = completionHandler;

    return [self __presentImagePickerControllerWithSourceType:sourceType];
}

#pragma mark - 私有方法 -

- (void)__showActionSheet
{
	UIAlertControllerStyle style = [UIDevice lx_isPad] ?
	UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;

	UIAlertController *alertController =
	[UIAlertController alertControllerWithTitle:self.title
										message:self.message
								 preferredStyle:style];

	UIAlertAction *photoAction =
	[UIAlertAction actionWithTitle:@"相册"
							 style:UIAlertActionStyleDefault
						   handler:^(UIAlertAction *action) {
							   [self __presentImagePickerControllerWithSourceType:
								UIImagePickerControllerSourceTypePhotoLibrary];
						   }];

	UIAlertAction *cameraAction =
	[UIAlertAction actionWithTitle:@"拍照"
							 style:UIAlertActionStyleDefault
						   handler:^(UIAlertAction *action) {
							   [self __presentImagePickerControllerWithSourceType:
								UIImagePickerControllerSourceTypeCamera];
						   }];

	UIAlertAction *cancelAction =
	[UIAlertAction actionWithTitle:@"取消"
							 style:UIAlertActionStyleCancel
						   handler:^(UIAlertAction *action) {
							   if (self.actionCancelHandler) {
								   self.actionCancelHandler();
							   }
						   }];

	[alertController addAction:photoAction];
	[alertController addAction:cameraAction];
	[alertController addAction:cancelAction];

	[[UIWindow lx_topViewController] presentViewController:alertController
												  animated:YES
												completion:nil];
}

- (BOOL)__presentImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {

        if (self.completionHandler) {
            if (self.unAvailableHandler) {
                self.unAvailableHandler();
            }
        } else if ([self.delegate respondsToSelector:@selector(imagePickerSourceTypeUnAvailable:)]) {
            [self.delegate imagePickerSourceTypeUnAvailable:self];
        }

        return NO;
    }

    UIImagePickerController *ipc = [UIImagePickerController new];

	ipc.delegate = self;
	ipc.sourceType = sourceType;
	ipc.allowsEditing = self.allowsEditing;

    [[UIWindow lx_topViewController] presentViewController:ipc animated:YES completion:nil];

    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage   = info[UIImagePickerControllerEditedImage];

    if (self.completionHandler) {
        self.completionHandler(originalImage, editedImage);
	} else {
		[self.delegate imagePicker:self
	 didFinishPickingOriginalImage:originalImage
					   editedImage:editedImage];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if (self.completionHandler) {
        if (self.cancelHandler) {
            self.cancelHandler();
        }
    } else if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}

@end

NS_ASSUME_NONNULL_END
