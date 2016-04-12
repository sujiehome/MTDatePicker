//
//  ViewController.m
//  MTDatePickerExample
//
//  Created by suyuxuan on 16/4/12.
//  Copyright © 2016年 Monk.Tang. All rights reserved.
//

#define iPhoneWidth     [UIScreen mainScreen].bounds.size.width
#define iPhoneHeight    [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "MTDatePickerView.h"

@interface ViewController ()

/** 自定义限制日期 */
@property (nonatomic, strong) UIButton *limitButton;

/** 默认限制日期 */
@property (nonatomic, strong) UIButton *defaultButton;

/** 带附加按钮 */
@property (nonatomic, strong) UIButton *additionalButton;

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    [self limitButton];
    [self defaultButton];
    [self additionalButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *)dateFromString:(NSString*)dateStr format:(NSString*)format
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [df setDateFormat:format];
    return [df dateFromString:dateStr];
}

#pragma mark - Click
- (void)buttonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10000:
        {
            MTDatePickerView *picker = [MTDatePickerView datePickerViewWithIsShowBar:YES
                                                                               title:@"测试1"
                                                                            leftText:@"取消"
                                                                           rightText:@"完成"
                                                                      additionalText:@"至今"];
            picker.mode = MTDatePickerModeDate;
            picker.minDate = [self dateFromString:@"19900101" format:@"yyyyMMdd"];
            picker.maxDate = [self dateFromString:@"20201231" format:@"yyyyMMdd"];
            picker.defaultDate = [NSDate date];
            
            [picker pickerSelected:^(NSDate *date) {
                NSLog(@"%@",date);
            } done:^(NSDate *date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择日期"
                                            message:[NSString stringWithFormat:@"%@",date]
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } additional:^(id date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择附加项"
                                            message:@"常用于至今"
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } cancel:^{
                NSLog(@"cancel");
            }];
            
            
            [picker show];
            
        }
            break;
        case 10001:
        {
            MTDatePickerView *picker = [MTDatePickerView datePickerViewWithIsShowBar:NO
                                                                               title:nil
                                                                            leftText:nil
                                                                           rightText:nil
                                                                      additionalText:nil];
            picker.mode = MTDatePickerModeDateYearAndMonth;
            picker.defaultDate = [self dateFromString:@"200005" format:@"yyyyMM"];
            
            [picker pickerSelected:^(NSDate *date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择日期"
                                            message:[NSString stringWithFormat:@"%@",date]
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } done:^(NSDate *date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择日期"
                                            message:[NSString stringWithFormat:@"%@",date]
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } additional:^(id date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择附加项"
                                            message:@"常用于至今"
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } cancel:^{
                NSLog(@"cancel");
            }];
            
            
            [picker show];
        }
            break;
        case 10002:
        {
            MTDatePickerView *picker = [MTDatePickerView datePickerViewWithIsShowBar:YES
                                                                               title:nil
                                                                            leftText:@"取消"
                                                                           rightText:@"完成"
                                                                      additionalText:@"至今"];
            
            [picker pickerSelected:^(NSDate *date) {
                NSLog(@"%@",date);
            } done:^(NSDate *date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择日期"
                                            message:[NSString stringWithFormat:@"%@",date]
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } additional:^(id date) {
                [[[UIAlertView alloc] initWithTitle:@"已选择附加项"
                                            message:@"常用于至今"
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil] show];
            } cancel:^{
                NSLog(@"cancel");
            }];
            
            
            [picker show];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Getter
- (UIButton *)limitButton
{
    if (!_limitButton) {
        _limitButton = [self buttonWithType:UIButtonTypeCustom];
        _limitButton.frame = CGRectMake(0, 40, iPhoneWidth, 40);
        _limitButton.tag = 10000;
        [_limitButton setTitle:@"1990-01-01  ~  2020-12-31"
                      forState:UIControlStateNormal];
        [self.view addSubview:_limitButton];
    }
    return _limitButton;
}

- (UIButton *)defaultButton
{
    if (!_defaultButton) {
        _defaultButton = [self buttonWithType:UIButtonTypeCustom];
        _defaultButton.frame = CGRectMake(0, 100, iPhoneWidth, 40);
        _defaultButton.tag = 10001;
        [_defaultButton setTitle:@"默认2000-05"
                        forState:UIControlStateNormal];
        [self.view addSubview:_defaultButton];
    }
    return _defaultButton;
}

- (UIButton *)additionalButton
{
    if (!_additionalButton) {
        _additionalButton = [self buttonWithType:UIButtonTypeCustom];
        _additionalButton.frame = CGRectMake(0, 160, iPhoneWidth, 40);
        _additionalButton.tag = 10002;
        [_additionalButton setTitle:@"附加字段(一般为至今)"
                           forState:UIControlStateNormal];
        [self.view addSubview:_additionalButton];
    }
    return _additionalButton;
}

#pragma mark - Factory
- (UIButton *)buttonWithType:(UIButtonType)buttonType
{
    UIButton *button = [UIButton buttonWithType:buttonType];
    button.layer.borderColor = [[UIColor blackColor] CGColor];
    button.layer.borderWidth = 1;
    [button setTitleColor:[UIColor blackColor]
                 forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(buttonClick:)
     forControlEvents:UIControlEventTouchUpInside];
    
    
    return button;
}

@end
