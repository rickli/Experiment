//
//  JPImageView.m
//  Experiment
//
//  Created by King on 2017/12/14.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "JPImageView.h"

@implementation JPImageView

- (UIImage *)getLaunchImage {
    NSDictionary * dict = @{@"320x480" : @"LaunchImage-700", @"320x568" : @"LaunchImage-700-568h", @"375x667" : @"LaunchImage-800-667h", @"414x736" : @"LaunchImage-800-Portrait-736h"};
    NSString * key = [NSString stringWithFormat:@"%dx%d", (int)[UIScreen mainScreen].bounds.size.width, (int)[UIScreen mainScreen].bounds.size.height];
    UIImage * launchImage = [UIImage imageNamed:dict[key]];
    return launchImage;
}

/** * @brief clip the cornerRadius with image, draw the backgroundColor you want, UIImageView must be setFrame before, no off-screen-rendered */
- (void)cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType backgroundColor:(UIColor *)backgroundColor {
    CGSize size = self.bounds.size;
    CGRect sizeBounds = self.bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return;
        }
        UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:sizeBounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
        UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:sizeBounds];
        [backgroundColor setFill];
        [backgroundRect fill];
        [cornerPath addClip];
        [image drawInRect:sizeBounds];
        id processedImageRef = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.contents = processedImageRef;
        });
    });
}


@end
