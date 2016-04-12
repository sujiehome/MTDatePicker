//
//  MTDatePickerView.h
//  MTDatePickerView
//
//  Created by Monk.Tang on 16/4/5.
//  Copyright © 2016年 Monk.Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MTDatePickerViewBlock)(NSDate *date);
typedef void(^MTDatePickerViewCancelBlock)();
typedef void(^MTDatePickerViewAdditionalBlock)(id date);

typedef NS_ENUM(NSInteger, MTDatePickerMode){
    /** 年月日 */
    MTDatePickerModeDate,
    /** 只有年 */
    MTDatePickerModeDateSingleYear,
    /** 年和月 */
    MTDatePickerModeDateYearAndMonth,
};

/** 
 自定义日期控件
 可选三种模式  年月日  年月  年
 可设置最大日期  最小日期  默认日期
 */
@interface MTDatePickerView : UIView
@property (nonatomic, copy) MTDatePickerViewBlock selectedBlock;
@property (nonatomic, copy) MTDatePickerViewBlock doneBlock;
@property (nonatomic, copy) MTDatePickerViewCancelBlock cancelBlock;
@property (nonatomic, copy) MTDatePickerViewAdditionalBlock additionalBlock;

/********** 日期设置 *************/
/** 最小日期 */
@property (nonatomic, strong) NSDate *minDate;
/** 最大日期 */
@property (nonatomic, strong) NSDate *maxDate;
/** 默认日期 */
@property (nonatomic, strong) NSDate *defaultDate;


/********** 初始化方法 ************/
+ (MTDatePickerView *)datePickerViewWithIsShowBar:(BOOL)isShow
                                            title:(NSString *)title
                                         leftText:(NSString *)leftText
                                        rightText:(NSString *)rightText
                                   additionalText:(NSString *)additionalText;//附加按钮，一般用来当做至今

/********** 展示方法 *************/
/** 展示模式 */
@property (nonatomic, assign) MTDatePickerMode mode;

/** 展示 */
- (void)show;


/********** 回调方法 *************/
- (void)pickerSelected:(MTDatePickerViewBlock)selectedBlock
                  done:(MTDatePickerViewBlock)doneBlock
            additional:(MTDatePickerViewAdditionalBlock)additionalBlock
                cancel:(MTDatePickerViewCancelBlock)cancelBlock;


@end
