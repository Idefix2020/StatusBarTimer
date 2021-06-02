#import "UIKit/UIKit.h"
#import <SpringBoard/SpringBoard.h>

@interface MTTimer : NSObject
-(double)duration;
-(double)remainingTime;
@end

@interface _UIStatusBarStringView
@property(retain, nonatomic) NSString *SBTOriginalText;
@property(retain, nonatomic) MTTimer *nextTimer;
@property(retain, nonatomic) NSTimer *oneSecTimer;
-(id)initWithFrame:(CGRect)arg1 ;
-(void)setText:(NSString *)arg1;
@end
