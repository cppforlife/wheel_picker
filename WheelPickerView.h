#import <UIKit/UIKit.h>

@class WheelPickerView;

@protocol WheelPickerViewDataSource <NSObject>
- (int)numberOfCellsForWheelPickerView:(WheelPickerView *)wheelPickerView;
- (int)heightForCellForWheelPickerView:(WheelPickerView *)wheelPickerView;
- (UITableViewCell *)wheelPickerView:(WheelPickerView *)wheelPickerView cellForRowAtIndex:(int)index;
@end

@interface WheelPickerView : UIView <UIScrollViewDelegate>
@property (nonatomic, assign) id<WheelPickerViewDataSource> dataSource;
@end
