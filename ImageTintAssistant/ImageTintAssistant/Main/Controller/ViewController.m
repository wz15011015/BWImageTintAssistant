//
//  ViewController.m
//  ChangeImageColor
//
//  Created by Hadlinks on 2018/8/30.
//  Copyright © 2018 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "ImageTintAssistant-Swift.h"
#import "ITACommon.h"
#import "UIImage+BWHelper.h"
#import "UIColor+BWHelper.h"

static NSString *const MainColorLabelPlaceholder = @"点击以获取图标主色调";

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UIImageView *originalImageView; // 原始图片
@property (nonatomic, strong) UILabel *mainColorLabel; // 图片主色调
@property (nonatomic, strong) ITARGBInputView *rgbView; // 颜色值输入视图
@property (nonatomic, strong) UIButton *tintButton; // 着色按钮
@property (nonatomic, strong) UIImageView *tintedImageView; // 着色后图片
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) UIImage *originalImage; // 原图片
@property (nonatomic, strong) UIColor *tintColor; // 着色颜色
@property (nonatomic, strong) UIImage *tintImage; // 着色图片
@property (nonatomic, copy) NSString *tintImageFilePath; // 着色图片沙盒路径
@property (nonatomic, assign) NSInteger red;
@property (nonatomic, assign) NSInteger green;
@property (nonatomic, assign) NSInteger blue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    // 设置默认图片
    self.originalImage = [UIImage imageNamed:@"example_icon.png"];
    self.originalImageView.image = self.originalImage;
    
    // 着色事件回调
    TYPE_WEAK_SELF;
    self.rgbView.rgbColorHandler = ^(UIColor *color, NSInteger red, NSInteger green, NSInteger blue) {
        weakSelf.tintColor = color;
        weakSelf.red = red;
        weakSelf.green = green;
        weakSelf.blue = blue;
        
        weakSelf.tintButton.backgroundColor = color;
    };
}

- (void)initUI {
    CGFloat imageViewW = 120;
    CGFloat imageViewX = (SCREEN_WIDTH - imageViewW) / 2.0;
    // 1. 原始图片
    self.originalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, NAVIGATION_BAR_HEIGHT, imageViewW, imageViewW)];
    self.originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.originalImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.originalImageView];
    
    UITapGestureRecognizer *originalTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(originalImageTap:)];
    [self.originalImageView addGestureRecognizer:originalTapGR];
    
    // 1.1 图片主色调
    self.mainColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.originalImageView.frame), SCREEN_WIDTH, 20)];
    self.mainColorLabel.textAlignment = NSTextAlignmentCenter;
    self.mainColorLabel.textColor = [UIColor grayColor];
    self.mainColorLabel.font = [UIFont systemFontOfSize:12];
    self.mainColorLabel.userInteractionEnabled = YES;
    self.mainColorLabel.text = MainColorLabelPlaceholder;
    [self.view addSubview:self.mainColorLabel];
    
    UITapGestureRecognizer *mainColorTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainColorTap)];
    [self.mainColorLabel addGestureRecognizer:mainColorTapGR];
    
    
    // 2. 颜色值输入视图
    self.rgbView = [[ITARGBInputView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.originalImageView.frame) + 20, SCREEN_WIDTH, 80)];
    [self.view addSubview:self.rgbView];
    
    // 3. 着色按钮
    CGFloat tintButtonW = 120;
    self.tintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tintButton.frame = CGRectMake((SCREEN_WIDTH - tintButtonW) / 2.0, CGRectGetMaxY(self.rgbView.frame) + 10, tintButtonW, 44);
    [self.tintButton setTitle:@" Tint" forState:UIControlStateNormal];
    [self.tintButton setTitleColor:RGBColor(23, 130, 210) forState:UIControlStateNormal];
    [self.tintButton setImage:[UIImage imageNamed:@"palette"] forState:UIControlStateNormal];
    [self.tintButton addTarget:self action:@selector(tintImageEvent) forControlEvents:UIControlEventTouchUpInside];
    self.tintButton.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tintButton];
    
    // 4. 着色后图片
    self.tintedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, CGRectGetMaxY(self.tintButton.frame) + 20, imageViewW, imageViewW)];
    self.tintedImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tintedImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.tintedImageView];
    
    UITapGestureRecognizer *tintTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tintImageTap:)];
    [self.tintedImageView addGestureRecognizer:tintTapGR];
    
    // 5. 转圈指示器
    if (@available(iOS 13.0, *)) {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.loadingView.frame = self.view.bounds;
    self.loadingView.center = self.view.center;
    self.loadingView.color = RGBColor(223, 126, 31);
    [self.view addSubview:self.loadingView];
    
    
    // 颜色适配Dark Mode
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
        
        UIColor *imageViewBackgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return RGBColor(26, 28, 30);
            } else {
                return RGBColor(251, 251, 251);
            }
        }];
        self.originalImageView.backgroundColor = imageViewBackgroundColor;
        self.tintedImageView.backgroundColor = imageViewBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.originalImageView.backgroundColor = RGBColor(251, 251, 251);
        self.tintedImageView.backgroundColor = RGBColor(251, 251, 251);
    }
}


#pragma mark - Override

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    CGFloat screen_width = size.width;
    CGFloat screen_height = size.height;
    
    // 更新控件位置
    CGFloat originalImageViewY = screen_width > screen_height ? 0 : NAVIGATION_BAR_HEIGHT;
    if (IS_IPAD) {
        originalImageViewY = NAVIGATION_BAR_HEIGHT;
    }
    CGFloat space = screen_width > screen_height ? 10 : 20;
    
    CGRect originalImageViewFrame = self.originalImageView.frame;
    originalImageViewFrame.origin.x = (screen_width - CGRectGetWidth(originalImageViewFrame)) / 2.0;
    originalImageViewFrame.origin.y = originalImageViewY;
    self.originalImageView.frame = originalImageViewFrame;
    
    CGRect mainColorFrame = self.mainColorLabel.frame;
    mainColorFrame.origin.x = 0;
    mainColorFrame.origin.y = CGRectGetMaxY(originalImageViewFrame);
    mainColorFrame.size.width = screen_width;
    mainColorFrame.size.height = space;
    self.mainColorLabel.frame = mainColorFrame;

    CGRect rgbViewFrame = self.rgbView.frame;
    rgbViewFrame.origin.x = (screen_width - CGRectGetWidth(rgbViewFrame)) / 2.0;
    rgbViewFrame.origin.y = CGRectGetMaxY(originalImageViewFrame) + space;
    self.rgbView.frame = rgbViewFrame;
    
    CGRect tintButtonFrame = self.tintButton.frame;
    tintButtonFrame.origin.x = (screen_width - CGRectGetWidth(tintButtonFrame)) / 2.0;
    tintButtonFrame.origin.y = CGRectGetMaxY(rgbViewFrame) + 10;
    self.tintButton.frame = tintButtonFrame;
    
    CGRect tintedImageViewFrame = self.tintedImageView.frame;
    tintedImageViewFrame.origin.x = (screen_width - CGRectGetWidth(tintedImageViewFrame)) / 2.0;
    tintedImageViewFrame.origin.y = CGRectGetMaxY(tintButtonFrame) + space;
    self.tintedImageView.frame = tintedImageViewFrame;
    
    self.loadingView.frame = CGRectMake(0, 0, screen_width, screen_height);
    self.loadingView.center = CGPointMake(screen_width / 2, screen_height / 2);
}


#pragma mark - Events

// 添加要着色图片事件
- (void)originalImageTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

/// 获取图标主色调
- (void)mainColorTap {
    [self.loadingView startAnimating];
    
    // 切换到新线程中执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *mainColor = [self.originalImage mainColor];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *rgbDic = [mainColor getRGBDictionary];
            int red   = [rgbDic[@"R"] intValue];
            int green = [rgbDic[@"G"] intValue];
            int blue  = [rgbDic[@"B"] intValue];
            int alpha = [rgbDic[@"A"] intValue];
            self.mainColorLabel.text = [NSString stringWithFormat:@"(%d, %d, %d, %d)", red, green, blue, alpha];
            self.mainColorLabel.userInteractionEnabled = NO;
            
            [self.loadingView stopAnimating];
        });
    });
}

// 着色事件
- (void)tintImageEvent {
    [self.view endEditing:YES];
    
    // 1. 原始图片
    if (!self.originalImage) {
        return;
    }
    // 2. 着色后图片
    self.tintImage = [self tintImage:self.originalImage tintColor:self.tintColor];
    // 显示着色后图片
    self.tintedImageView.image = self.tintImage;
    
    // 3. 图片写入到沙盒
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *tintImageName = [NSString stringWithFormat:@"/tint_image_RGB(%d,%d,%d)_%@.png", (int)self.red, (int)self.green, (int)self.blue, dateStr];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPathToFile = [documentsDirectory stringByAppendingString:tintImageName];
    
    NSData *tintImageData = UIImagePNGRepresentation(self.tintImage);
    [tintImageData writeToFile:fullPathToFile atomically:NO];
    
    // 4. 图片的沙盒路径
    self.tintImageFilePath = [documentsDirectory stringByAppendingPathComponent:tintImageName];
    NSLog(@"着色图片的沙盒路径: %@", self.tintImageFilePath);
}

// 导出着色图片事件
- (void)tintImageTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (IS_NULL_STRING(self.tintImageFilePath)) { // 文件路径为空
        return;
    }
    
    // 1. 读取图片文件
    NSURL *fileURL = [NSURL fileURLWithPath:self.tintImageFilePath];
    
    // 2. 弹出系统分享控制器
    NSArray *itemsArr = @[fileURL];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsArr applicationActivities:nil];
//    [self presentViewController:activityViewController animated:YES completion:nil];
    
    // 为了适配iPad,使用UIPopoverPresentationController
    UIPopoverPresentationController *popVC = activityViewController.popoverPresentationController;
    popVC.delegate = self;
//    popVC.permittedArrowDirections = UIPopoverArrowDirectionUp; // 设置允许的方向
    popVC.sourceView = self.tintedImageView;
    popVC.sourceRect = CGRectMake(CGRectGetWidth(self.tintedImageView.frame), CGRectGetHeight(self.tintedImageView.frame) / 2, 0, 0); // 设置箭头锚点的位置 (CGRectMake(0, 0, 0, 0): sourceView的左上角)
    popVC.canOverlapSourceViewRect = YES;
    [self presentViewController:activityViewController animated:YES completion:nil];
}


#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationPopover;
}


#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.originalImage = originalImage;
    self.originalImageView.image = self.originalImage;
    
    self.mainColorLabel.text = MainColorLabelPlaceholder;
    self.mainColorLabel.userInteractionEnabled = YES;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Override

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - Tool Methods

/** 给图片添加颜色滤镜 */
- (UIImage *)tintImage:(UIImage *)image tintColor:(UIColor *)tintColor {
    CGSize size = image.size;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    // 1. 创建一个基于位图的上下文 (内存中开辟一块空间,和屏幕无关!)
    /**
     * size: 绘图的尺寸
     * opaque (不透明度): true 不透明 / false 透明
     * scale (屏幕分辨率): 指定为0时,则默认使用当前设备的屏幕分辨率,其他例如: 1.0f  2.0f  3.0f
     */
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    
    // 2. 设置填充颜色
    [tintColor setFill];
    UIRectFill(bounds);
    
    // 3. 绘制图像
    // kCGBlendModeOverlay能保留灰度信息,kCGBlendModeDestinationIn能保留透明度信息
//    [image drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    // 4. 从图像上下文获取图像
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 5. 关闭图像上下文
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

/** 给图片添加圆角 */
- (UIImage *)cornerImage:(UIImage *)image radius:(CGFloat)radius {
    CGSize size = image.size;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    // 1. 创建一个基于位图的上下文 (内存中开辟一块空间,和屏幕无关!)
    /**
     * size: 绘图的尺寸
     * opaque (不透明度): true 不透明 / false 透明
     * scale (屏幕分辨率): 指定为0时,则默认使用当前设备的屏幕分辨率,其他例如: 1.0f  2.0f  3.0f
     */
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
    
    // 2. 绘制图像
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
    // 使用BezierPath进行剪切
    [path addClip];
    // 绘制图像
    [image drawInRect:bounds];
    
    // 3. 从图像上下文获取图像
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4. 关闭图像上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - Getters

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePickerController;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
