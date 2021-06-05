#import "Tweak.h"

#ifdef DEBUG
#define ALERT(...) do {                                                             \
NSString *alertString = [NSString stringWithFormat:__VA_ARGS__];                    \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Idefix2020 Debug Alert"   \
    message:alertString                                                             \
    delegate:nil                                                                    \
    cancelButtonTitle:@"OK"                                                         \
    otherButtonTitles:nil];                                                         \
[alert show];                                                                       \
} while(0)
#else
#define ALERT(...)
#endif

bool showTimer = YES;

%hook _UIStatusBarStringView

%property(retain, nonatomic) NSString *SBTOriginalText;
%property(retain, nonatomic) MTTimer *nextTimer;
%property(retain, nonatomic) NSTimer *oneSecTimer;

-(id)initWithFrame:(CGRect)arg1 {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MTTimerManagerNextTimerChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerNotification:) name:@"MTTimerManagerNextTimerChanged" object:nil];

    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnView:)];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:gesture];
    
    return %orig(arg1);
}

-(void)setText:(NSString *)arg1{

    [self setUserInteractionEnabled:YES];

    self.SBTOriginalText = arg1;

    bool showInThisView = NO;

    UIWindow *keyWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }

    // If the device has a notch only apply to views in the left quarter of the screen,
    // if it doesn't only apply to views in the middle third of the screen
    if ([keyWindow safeAreaInsets].bottom > 0) {
        if (self.frame.origin.x < ([UIScreen mainScreen].bounds.size.width/4))
        {
            showInThisView = YES;
        }
    }
    else {
        if ((self.frame.origin.x > ([UIScreen mainScreen].bounds.size.width/3)) && (self.frame.origin.x < ([UIScreen mainScreen].bounds.size.width/3)*2))
        {
            showInThisView = YES;
        }
    }

    if (showTimer && showInThisView)
    {
        long seconds = [self.nextTimer remainingTime];

        if (seconds >= 3600)
        {
            %orig([NSString stringWithFormat:@"%2ld:%02ld:%02ld", seconds/3600, (seconds%3600)/60, seconds%60]);
        }
        else if (seconds != 0)
        {
            %orig([NSString stringWithFormat:@"%02ld:%02ld", seconds/60, seconds%60]);
        }
        else {
            %orig(arg1);
        }
    }
    else {
        %orig(arg1);
    }
}
%new
-(void) timerNotification:(NSNotification *)notification {
    self.nextTimer = [[notification userInfo] objectForKey:@"NextTimer"];

    if (self.nextTimer == nil)
    {
        [self.oneSecTimer invalidate];
        self.oneSecTimer = nil;
    }
    else {
        self.oneSecTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    }
}
%new
-(void) updateCountdown {
    NSString *originalText = self.SBTOriginalText;
    [self setText:originalText];
}
%new
-(void) userTappedOnView:(UIGestureRecognizer *)gestureRecognizer {
    showTimer = !showTimer;
    NSString *originalText = self.SBTOriginalText;
    [self setText:originalText];
}
%end
