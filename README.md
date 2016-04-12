# iOS MTDatePicker

## 自定义日期选择器


###1 解决问题
* 解决系统日期选择器不可以单独选择年，或只选择年月的问题。
* 解决系统日期选择器不支持选择至今的问题。
* 增加自定义工具栏，可选择是否显示。
* 增加自定义附加按钮（一般用来选择至今、无限等）。

###2 支持功能
* 支持设置显示年，年月，年月日三种模式。
* 支持设置最大日期，最小日期限制以及分别限制。
* 支持设置默认日期。
* 支持2月闰年识别。

###3 待改善 限制
##### 工具栏以及工具按钮目前对外没有自定义接口
````
如想更改，可以在 MTDatePickerView.m 类中 getter分组标签下，自行更改按钮样式。
如：
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

````

##### 如没有在外部局限最大/小日期，默认会计算最小日期为当前年份向前30年，最大日期为当前年份延后10年
````
如需更改，可以在 MTDatePickerView.m 类中 第14-17行修改。
如：
/** 默认最大日期延后年份 */
static NSInteger const kMaxYear = 10;
/** 默认最小日期提前年份 */
static NSInteger const kMinYear = 30;

````

###4 集成方式
#####三种模式支持
````
/** 年月日 */
MTDatePickerModeDate
/** 只有年 */
MTDatePickerModeDateSingleYear
/** 年和月 */
MTDatePickerModeDateYearAndMonth
````
#####日期设置
````
/********** 日期设置 *************/
/** 最小日期 */
@property (nonatomic, strong) NSDate *minDate;
/** 最大日期 */
@property (nonatomic, strong) NSDate *maxDate;
/** 默认日期 */
@property (nonatomic, strong) NSDate *defaultDate;
````
#####初始化方法
````
+ (MTDatePickerView *)datePickerViewWithIsShowBar:(BOOL)isShow
                                            title:(NSString *)title
                                         leftText:(NSString *)leftText
                                        rightText:(NSString *)rightText
                                   additionalText:(NSString *)additionalText;
                                   
如isShow赋值为NO，则title，leftText，rightText，additionalText不会生效。
如isShow赋值为YES，title，leftText，rightText，additionalText传nil就不会创建该控件
additionalText为附加按钮，一般用来当做至今，不限等。

````
#####展示方法
````
/********** 展示方法 *************/
/** 展示模式 */
@property (nonatomic, assign) MTDatePickerMode mode;

/** 展示 */
- (void)show;
````
#####回调方法
````
/********** 回调方法 *************/
- (void)pickerSelected:(MTDatePickerViewBlock)selectedBlock
                  done:(MTDatePickerViewBlock)doneBlock
            additional:(MTDatePickerViewAdditionalBlock)additionalBlock
                cancel:(MTDatePickerViewCancelBlock)cancelBlock;
````

#####集成示例
````
MTDatePickerView *picker = [MTDatePickerView datePickerViewWithIsShowBar:YES
                                                                   title:@"测试"
                                                                leftText:@"取消"
                                                               rightText:@"完成"
                                                          additionalText:@"至今"];
picker.mode = MTDatePickerModeDate;
picker.minDate = [self dateFromString:@"19900101" format:@"yyyyMMdd"];
picker.maxDate = [self dateFromString:@"20201231" format:@"yyyyMMdd"];
picker.defaultDate = [NSDate date];

[picker pickerSelected:^(NSDate *date) {
    //选择调用
} done:^(NSDate *date) {
    //完成调用
} additional:^(id date) {
    //附加调用
} cancel:^{
    //取消调用
}];

[picker show];
````

###5 交流
````
如有bug或不足，接受各类pullRequest

如有沟通交流，请联系QQ:391664725  注明 MTPanBack

````