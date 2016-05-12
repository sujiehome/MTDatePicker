//
//  MTDatePickerView.m
//  MTDatePickerView
//
//  Created by Monk.Tang on 16/4/5.
//  Copyright © 2016年 Monk.Tang. All rights reserved.
//

#define iPhoneWidth     [UIScreen mainScreen].bounds.size.width
#define iPhoneHeight    [UIScreen mainScreen].bounds.size.height

#import "MTDatePickerView.h"

/** 默认最大日期延后年份 */
static NSInteger const kMaxYear = 10;
/** 默认最小日期提前年份 */
static NSInteger const kMinYear = 30;

@interface MTDatePickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

/** 工具栏 */
@property (nonatomic, strong) UIView *toolBar;

/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 左侧按钮 */
@property (nonatomic, strong) UIButton *leftButton;

/** 右侧按钮 */
@property (nonatomic, strong) UIButton *rightButton;

/** 附加按钮(一般用来当做至今) */
@property (nonatomic, strong) UIButton *additionalButton;

/** picker */
@property (nonatomic, strong) UIPickerView *picker;

/** 灰色背景 */
@property (nonatomic, strong) UIView *grayBG;

/** picker背景 */
@property (nonatomic, strong) UIView *pickerBG;

/** 数据源 */
@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dayArray;

@property (nonatomic, strong) NSArray *standardMonthArray;

/** 选中数据源 */
@property (nonatomic, copy) NSString *selectedYear;
@property (nonatomic, copy) NSString *selectedMonth;
@property (nonatomic, copy) NSString *selectedDay;

@end

@implementation MTDatePickerView

#pragma mark - init
+ (MTDatePickerView *)datePickerViewWithIsShowBar:(BOOL)isShow
                                            title:(NSString *)title
                                         leftText:(NSString *)leftText
                                        rightText:(NSString *)rightText
                                   additionalText:(NSString *)additionalText
{
    MTDatePickerView *pickerView = [[MTDatePickerView alloc] init];
    pickerView.frame = [UIScreen mainScreen].bounds;
    pickerView.mode = MTDatePickerModeDate;
    [pickerView grayBG];
    [pickerView pickerBG];
    [pickerView picker];
    
    if (isShow) {
        [pickerView toolBar];
        pickerView.picker.frame = CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 200);
        if (title) {
            pickerView.titleLabel.text = title;
            [pickerView.titleLabel sizeToFit];
            pickerView.titleLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 22);
        }
        if (leftText) {
            [pickerView.leftButton setTitle:leftText forState:UIControlStateNormal];
        }
        if (rightText) {
            [pickerView.rightButton setTitle:rightText forState:UIControlStateNormal];
        }
        if (additionalText) {
            [pickerView.additionalButton setTitle:additionalText forState:UIControlStateNormal];
        }
    }else
    {
        pickerView.pickerBG.frame = CGRectMake(0,
                                               [UIScreen mainScreen].bounds.size.height - 200,
                                               [UIScreen mainScreen].bounds.size.width,
                                               200);
        pickerView.picker.frame = CGRectMake(0,
                                             0,
                                             [UIScreen mainScreen].bounds.size.width,
                                             200);
    }
    
    return pickerView;
}

#pragma mark - show
- (void)show
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self checkLimitYear];
    [self reloadDefault];
    
    if (!self.defaultDate) {
        [self setDefaultDate:nil];
    }
}

#pragma mark - method
- (void)reloadDefault
{
    if (self.selectedYear != nil && self.selectedYear.length != 0) {
        NSUInteger yearIndex = [self.yearArray indexOfObject:self.selectedYear];
        if (yearIndex != NSNotFound) {
            [self.picker selectRow:yearIndex inComponent:0 animated:YES];
        }
    }
    if (self.selectedMonth != nil && self.selectedMonth.length != 0) {
        NSUInteger monthIndex = [self.monthArray indexOfObject:self.selectedMonth];
        if (monthIndex != NSNotFound) {
            if (self.mode == MTDatePickerModeDate || self.mode == MTDatePickerModeDateYearAndMonth) {
                [self.picker selectRow:monthIndex inComponent:1 animated:YES];
            }
        }
    }
    if (self.selectedDay != nil && self.selectedDay.length != 0) {
        NSUInteger dayIndex = [self.dayArray indexOfObject:self.selectedDay];
        if (dayIndex != NSNotFound) {
            if (self.mode == MTDatePickerModeDate) {
                [self.picker selectRow:dayIndex inComponent:2 animated:YES];
            }
        }
    }
}

- (void)checkLimitYear
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    if (self.minDate != nil && self.maxDate != nil) {
        NSInteger minYear = [[self getNowDate:self.minDate] year];
        NSInteger maxYear = [[self getNowDate:self.maxDate] year];
        
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = (int)minYear; i <= maxYear; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d年",i]];
        }
        self.yearArray = [marr copy];
    }else if (self.minDate != nil) {
        NSInteger minYear = [[self getNowDate:self.minDate] year];
        
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = (int)minYear; i <= [[self getNowDate:[NSDate date]] year] + kMaxYear; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d年",i]];
        }
        self.yearArray = [marr copy];
    }else if (self.maxDate != nil) {
        NSInteger maxYear = [[self getNowDate:self.maxDate] year];
        
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = (int)[[self getNowDate:[NSDate date]] year] - kMinYear; i <= maxYear; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d年",i]];
        }
        self.yearArray = [marr copy];
    }
    [self.picker reloadAllComponents];
}

- (NSArray *)checkDaysWithYear:(NSString *)yearStr month:(NSString *)monthStr
{
    //计算每月多少天
    NSMutableArray *arr = [@[] mutableCopy];
    NSInteger year = [[yearStr substringToIndex:yearStr.length - 1] integerValue];
    NSInteger month = [[monthStr substringToIndex:monthStr.length - 1] integerValue];
    BOOL isLeapYear = NO;
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        isLeapYear = YES;
    }
    
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
        {
            for (int i = 1; i < 32; i++) {
                [arr addObject:[NSString stringWithFormat:@"%d日",i]];
            }
            return [arr copy];
        }
            break;
        case 2:
        {
            if (isLeapYear) {
                //闰年 29天
                for (int i = 1; i < 30; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d日",i]];
                }
                return [arr copy];
            }else
            {
                for (int i = 1; i < 29; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d日",i]];
                }
                return [arr copy];
            }
        }
            break;
        default:
        {
            for (int i = 1; i < 31; i++) {
                [arr addObject:[NSString stringWithFormat:@"%d日",i]];
            }
            return [arr copy];
        }
            break;
    }
    
    return arr;
}

- (NSArray *)checkLimitDaysWithYear:(NSString *)yearStr month:(NSString *)monthStr
{
    NSArray *array = [self checkDaysWithYear:yearStr month:monthStr];
    self.monthArray = [self checkLimitMonthWithYear:yearStr];
    if ([self.yearArray indexOfObject:yearStr] == self.yearArray.count - 1 &&
        [self.monthArray indexOfObject:monthStr] == self.monthArray.count - 1 &&
        self.maxDate != nil) {
        //选中最大年份 最大月份
        NSInteger maxDay = [[self getNowDate:self.maxDate] day];
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = 1; i <= maxDay; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d日",i]];
        }
        
        if ([marr indexOfObject:self.selectedDay] == NSNotFound) {
            self.selectedDay = [marr lastObject];
        }
        
        return [marr copy];
        
    }else if ([self.yearArray indexOfObject:yearStr] == 0 &&
              [self.monthArray indexOfObject:monthStr] == 0 &&
              self.minDate != nil) {
        //选中最小年份 最小月份
        NSInteger minDay = [[self getNowDate:self.minDate] day];
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = (int)minDay; i <= array.count; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d日",i]];
        }
        
        if ([marr indexOfObject:self.selectedDay] == NSNotFound) {
            self.selectedDay = [marr firstObject];
        }
        
        return [marr copy];
    }
    
    return array;
}

- (NSArray *)checkLimitMonthWithYear:(NSString *)yearStr
{
    if ([self.yearArray indexOfObject:yearStr] == self.yearArray.count - 1 &&
        self.maxDate != nil) {
        //选中最大年份
        NSInteger maxMonth = [[self getNowDate:self.maxDate] month];
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = 1; i <= maxMonth; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d月",i]];
        }
        
        if ([marr indexOfObject:self.selectedMonth] == NSNotFound) {
            self.selectedMonth = [marr lastObject];
        }
        
        return self.monthArray = [marr copy];
    }else if ([self.yearArray indexOfObject:yearStr] == 0 &&
              self.minDate != nil) {
        //选中最小年份
        NSInteger minMonth = [[self getNowDate:self.minDate] month];
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = (int)minMonth; i <= 12; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d月",i]];
        }
        
        if ([marr indexOfObject:self.selectedMonth] == NSNotFound) {
            self.selectedMonth = [marr firstObject];
        }
        
        return self.monthArray = [marr copy];
    }
    
    return self.monthArray = self.standardMonthArray;
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.mode) {
        case MTDatePickerModeDate:
            return 3;
            break;
        case MTDatePickerModeDateSingleYear:
            return 1;
            break;
        case MTDatePickerModeDateYearAndMonth:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.yearArray.count;
    }else if (component == 1)
    {
        return [self checkLimitMonthWithYear:self.selectedYear].count;
    }else if (component == 2)
    {
        return [self checkLimitDaysWithYear:self.selectedYear month:self.selectedMonth].count;
    }else
    {
        return 0;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, _picker.frame.size.width, 40);
    label.font = [UIFont systemFontOfSize:20];
    if (component == 0) {
        label.text = self.yearArray[row];
    }else if (component == 1) {
        label.text = self.monthArray[row];
    }else if (component == 2) {
        label.text = self.dayArray[row];
    }
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedYear = self.yearArray[row];
        self.dayArray = [self checkLimitDaysWithYear:self.selectedYear month:self.selectedMonth];
        if (self.mode == MTDatePickerModeDate) {
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        }
        if (self.mode == MTDatePickerModeDateYearAndMonth) {
            [pickerView reloadComponent:1];
        }
    }else if (component == 1) {
        self.selectedMonth = self.monthArray[row];
        self.dayArray = [self checkLimitDaysWithYear:self.selectedYear month:self.selectedMonth];
        if (self.mode == MTDatePickerModeDate) {
            [pickerView reloadComponent:2];
        }
    }else if (component == 2) {
        self.selectedDay = self.dayArray[row];
    }
    
    self.selectedBlock([self getSelectDate]);
}

#pragma mark - call back
- (void)pickerSelected:(MTDatePickerViewBlock)selectedBlock
                  done:(MTDatePickerViewBlock)doneBlock
            additional:(MTDatePickerViewAdditionalBlock)additionalBlock
                cancel:(MTDatePickerViewCancelBlock)cancelBlock;
{
    self.selectedBlock = selectedBlock;
    self.doneBlock = doneBlock;
    self.additionalBlock = additionalBlock;
    self.cancelBlock = cancelBlock;
}

#pragma mark - click
- (void)buttonClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 10000:
        {
            //取消
            if (self.cancelBlock) {
                self.cancelBlock();
            }
        }
            break;
        case 10001:
        {
            //确定
            if (self.doneBlock) {
                self.doneBlock([self getSelectDate]);
            }
        }
            break;
        case 10002:
        {
            //附加(一般当做至今)
            if (self.additionalBlock) {
                self.additionalBlock(@"999999");
            }
        }
            break;
        default:
            break;
    }
    
    [self removeFromSuperview];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self removeFromSuperview];
}

- (NSDate *)getSelectDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@%@%@",self.selectedYear, self.selectedMonth, self.selectedDay]];
    return date;
}

#pragma mark - tools
- (NSDateComponents *)getNowDate:(NSDate *)date
{//根据日期获取日期组成部分
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return dateComponent;
}

#pragma mark - setter
- (void)setDefaultDate:(NSDate *)defaultDate
{
    _defaultDate = defaultDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *defaultStr = [formatter stringFromDate:defaultDate];
    if (defaultStr) {
        self.selectedYear = [NSString stringWithFormat:@"%@年",[defaultStr substringToIndex:4]];
        self.selectedMonth = [NSString stringWithFormat:@"%d月",(int)[[defaultStr substringWithRange:NSMakeRange(5, 2)] integerValue]];
        self.selectedDay = [NSString stringWithFormat:@"%d日",(int)[[defaultStr substringWithRange:NSMakeRange(8, 2)] integerValue]];
    }else
    {
        self.selectedYear = self.yearArray[0];
        self.selectedMonth = self.monthArray[0];
        self.selectedDay = self.dayArray[0];
    }
}

#pragma mark - getter
- (UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] init];
        _toolBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        _toolBar.backgroundColor = [UIColor grayColor];
        [self.pickerBG addSubview:_toolBar];
    }
    return _toolBar;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0, 0, 150, 44);
        _titleLabel.center = CGPointMake(iPhoneWidth / 2, _titleLabel.center.y) ;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.toolBar addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(15, 7, 55, 28);
        _leftButton.backgroundColor = [UIColor whiteColor];
        _leftButton.layer.cornerRadius = 4;
        _leftButton.layer.masksToBounds = YES;
        _leftButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _leftButton.layer.borderWidth = 1;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _leftButton.tag = 10000;
        [_leftButton setTitle:@"取消"
                       forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor blackColor]
                            forState:UIControlStateNormal];
        [_leftButton addTarget:self
                          action:@selector(buttonClick:)
                forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:_leftButton];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(iPhoneWidth - 15 - 55, 7, 55, 28);
        _rightButton.backgroundColor = [UIColor whiteColor];
        _rightButton.layer.cornerRadius = 4;
        _rightButton.layer.masksToBounds = YES;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightButton.tag = 10001;
        [_rightButton setTitle:@"确定"
                     forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
        [_rightButton addTarget:self
                        action:@selector(buttonClick:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:_rightButton];
    }
    return _rightButton;
}

- (UIButton *)additionalButton
{
    if (!_additionalButton) {
        _additionalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _additionalButton.frame = CGRectMake(iPhoneWidth - 15 * 2 - 55 * 2, 7, 55, 28);
        _additionalButton.backgroundColor = [UIColor whiteColor];
        _additionalButton.layer.cornerRadius = 4;
        _additionalButton.layer.masksToBounds = YES;
        _additionalButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _additionalButton.layer.borderWidth = 1;
        _additionalButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _additionalButton.tag = 10002;
        [_additionalButton setTitle:@"至今"
                           forState:UIControlStateNormal];
        [_additionalButton setTitleColor:[UIColor blackColor]
                                forState:UIControlStateNormal];
        [_additionalButton addTarget:self
                              action:@selector(buttonClick:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.toolBar addSubview:_additionalButton];
    }
    return _additionalButton;
}

- (UIPickerView *)picker
{
    if (!_picker) {
        _picker = [[UIPickerView alloc] init];
        _picker.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
        _picker.delegate = self;
        _picker.dataSource = self;
        [self.pickerBG addSubview:_picker];
    }
    return _picker;
}

- (UIView *)grayBG
{
    if (!_grayBG) {
        _grayBG = [[UIView alloc] init];
        _grayBG.frame = [UIScreen mainScreen].bounds;
        _grayBG.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        [_grayBG addGestureRecognizer:tap];
        
        [self addSubview:_grayBG];
    }
    return _grayBG;
}

- (UIView *)pickerBG
{
    if (!_pickerBG) {
        _pickerBG = [[UIView alloc] init];
        _pickerBG.frame = CGRectMake(0,
                                     [UIScreen mainScreen].bounds.size.height - 244,
                                     [UIScreen mainScreen].bounds.size.width,
                                     244);
        _pickerBG.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerBG];
    }
    return _pickerBG;
}

- (NSArray *)yearArray
{
    if (!_yearArray) {
        NSMutableArray *marr = [@[] mutableCopy];
        int nowYear = (int)[[self getNowDate:[NSDate date]] year];
        for (int i = nowYear - kMinYear; i < nowYear + kMaxYear; i++) {
            //默认前20年  后10年
            [marr addObject:[NSString stringWithFormat:@"%d年",i]];
        }
        _yearArray = [marr copy];
    }
    return _yearArray;
}

- (NSArray *)monthArray
{
    if (!_monthArray) {
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = 1; i < 13; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d月",i]];
        }
        
        _monthArray = [marr copy];
    }
    return _monthArray;
}

- (NSArray *)dayArray
{
    if (!_dayArray) {
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = 1; i < 32; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d日",i]];
        }
        _dayArray = [marr copy];
    }
    return _dayArray;
}

- (NSArray *)standardMonthArray
{
    if (!_standardMonthArray) {
        NSMutableArray *marr = [@[] mutableCopy];
        for (int i = 1; i < 13; i++) {
            [marr addObject:[NSString stringWithFormat:@"%d月",i]];
        }
        _standardMonthArray = [marr copy];
    }
    return _standardMonthArray;
}

@end
