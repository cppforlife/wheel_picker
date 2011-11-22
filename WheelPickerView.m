#import "WheelPickerView.h"

@interface WheelPickerView ()
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, assign) int numberOfCells;
@property (nonatomic, assign) int cellHeight;

@property (nonatomic, assign) BOOL draggingEnded;
@property (nonatomic, assign) float lastYOffset;
@property (nonatomic, assign) double lastTime;

- (void)initialize;
- (void)populate;
@end


@implementation WheelPickerView

@synthesize 
    dataSource = dataSource_,
    scrollView = scrollView_, 
    numberOfCells = numberOfCells_, 
    cellHeight = cellHeight_,
    draggingEnded = draggingEnded_,
    lastYOffset = lastYOffset_,
    lastTime = lastTime_;

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])){
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    self.scrollView.delegate = self;
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    [self addSubview:self.scrollView];
}

- (void)dealloc {
    self.scrollView = nil;
    [super dealloc];
}

- (void)setDataSource:(id<WheelPickerViewDataSource>)dataSource {
    dataSource_ = dataSource;
    [self populate];
}

- (void)populate {
    numberOfCells_ = [self.dataSource numberOfCellsForWheelPickerView:self];
    cellHeight_ = [self.dataSource heightForCellForWheelPickerView:self];
    
    int contentSizeHeight = (numberOfCells_-1)*cellHeight_ + self.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, contentSizeHeight);
    
    // first cell will be centered on the screen
    int firstCellYOffset = self.frame.size.height/2 - cellHeight_/2;
    
    for (int i=0; i<numberOfCells_; ++i) {
        UITableViewCell *cell = [self.dataSource wheelPickerView:self cellForRowAtIndex:i];
        cell.frame = CGRectMake(0, i*cellHeight_ + firstCellYOffset, self.frame.size.width, cellHeight_);
        [self.scrollView addSubview:cell];
    }
}

- (int)desiredYOffset:(int)offset {
    // if scrolled more than half way into a next cell, scroll the remaining distance;
    // otherwise snap back to previous cell
    int remainingDistanceUntilNextCell = offset % cellHeight_;
    
    if (remainingDistanceUntilNextCell > cellHeight_/2) {
        return offset + (cellHeight_ - remainingDistanceUntilNextCell);
    } else {
        return offset - remainingDistanceUntilNextCell;
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    draggingEnded_ = YES;
    lastYOffset_ = 0;
    lastTime_ = 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    draggingEnded_ = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (draggingEnded_) {
        float currentYOffset = scrollView.contentOffset.y;
        double currentTime = CFAbsoluteTimeGetCurrent();
        
        if (lastTime_ > 0) {
            double velocity = (currentYOffset - lastYOffset_) / (currentTime - lastTime_);
            
            // snap to the nearest cell only if deceleration rate reached a certain value
            // and scroll view is not bouncing (we do not want to interfere with default bouncing)
            if (fabs(velocity) < 100 && currentYOffset > 0 && currentYOffset < (scrollView.contentSize.height - self.frame.size.height)) {
                int desiredOffset = [self desiredYOffset:currentYOffset];
                [scrollView setContentOffset:CGPointMake(0, desiredOffset) animated:YES];
            }
        }
        
        lastYOffset_ = currentYOffset;
        lastTime_ = currentTime;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        int desiredOffset = [self desiredYOffset:scrollView.contentOffset.y];
        [scrollView setContentOffset:CGPointMake(0, desiredOffset) animated:YES];
    }
}

@end
