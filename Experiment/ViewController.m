//
//  ViewController.m
//  Experiment
//
//  Created by King on 2017/12/12.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "ViewController.h"
#import "JPMultiThread.h"
#import "JPImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *teleCarrierName;
@property (weak, nonatomic) IBOutlet UILabel *telephoneNumber;
@property (weak, nonatomic) IBOutlet JPImageView *resizeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    JPMultiThread *thread = [[JPMultiThread alloc] init];
    
    // JPImage resize
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *resourcePath = [bundle resourcePath];
//    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"fstpevfuwuqo7.png"];
//    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//    [_resizeImageView cornerRadiusWithImage:image cornerRadius:self.resizeImageView.frame.size.width/2 rectCornerType:UIRectCornerAllCorners backgroundColor:[UIColor whiteColor]];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
