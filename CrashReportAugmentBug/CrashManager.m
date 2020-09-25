//
//  ADOBE CONFIDENTIAL
//  __________________
//
//  Copyright 2020 Adobe 
//  All Rights Reserved.
//
//  NOTICE:  All information contained herein is, and remains
//  the property of Adobe and its suppliers, if any. The intellectual
//  and technical concepts contained herein are proprietary to Adobe
//  and its suppliers and are protected by all applicable intellectual
//  property laws, including trade secret and copyright laws.
//  Dissemination of this information or reproduction of this material
//  is strictly forbidden unless prior written permission is obtained
//  from Adobe.
//

#import "UIKit/UIKit.h"

#import "CrashManager.h"

#import "Firebase.h"

#include <pwd.h>

@interface CrashManager()

@end

static NSString* kLaunchCountKey = @"CrashTestLaunchCount";

@implementation CrashManager

+ (instancetype)sharedInstance {
	static CrashManager* _manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_manager = [CrashManager new];
	});

	return _manager;
}

- (void)setUpOnce {
	[FIRApp configure];
	[FIRCrashlytics.crashlytics setCrashlyticsCollectionEnabled:NO];
    [FIRCrashlytics.crashlytics setUserID:self.userID];

    long count = self.lastSessionLaunchCount;
    NSString *last_session_string = [NSString stringWithFormat:@"last session launch count: %ld", (long)count];

	[FIRCrashlytics.crashlytics setCustomValue:NSDate.date forKey:@"launch_timestamp"];
	[FIRCrashlytics.crashlytics setCustomValue:@(count) forKey:@"last_session_launch_count"];

	[FIRCrashlytics.crashlytics log:last_session_string];
}

- (NSString*)userID {
    NSUUID *deviceID = UIDevice.currentDevice.identifierForVendor;
    NSString *uuidString = deviceID.UUIDString;
    NSRange range = NSMakeRange(0, 5);
    return [uuidString substringWithRange:range];
}

- (void)incrementLaunchCount {
    // only permit this once per session. Subsequent calls do nothing.
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        [[NSUserDefaults standardUserDefaults] setInteger:self.lastSessionLaunchCount + 1 forKey:kLaunchCountKey];
	});
}

- (NSInteger)lastSessionLaunchCount {
	static NSInteger value;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		value = [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchCountKey];
	});

	return value;
}

- (NSInteger)currentSessionLaunchCount {
	return [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchCountKey];
}

- (BOOL)didCrashOnPreviousLaunch {
	return [[FIRCrashlytics crashlytics] didCrashDuringPreviousExecution];
}

- (void)crashWithType:(CrashType)type {
	switch (type) {
		case CrashTypeAssertion: {
            assert(false);
        } break;

		case CrashTypeException: {
            @throw [NSException exceptionWithName:@"TestCrashException"
                                           reason:@"Test crash: exception"
                                         userInfo:nil];
        } break;

		case CrashTypeBadIndex: {
            NSString* i = @[][self.lastSessionLaunchCount];
            NSLog(@"Crashed with %@", i);
        } break;
	}
}

- (void)sendCrashReport:(UIViewController*)parent {
    // To simulate our crash report feedback taking some time, we put a delay on this reporting.
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [FIRCrashlytics.crashlytics setCustomValue:@(self.lastSessionLaunchCount) forKey:@"crash_feedback_for_session"];

        [FIRCrashlytics.crashlytics checkForUnsentReportsWithCompletion:^(BOOL hasUnsentReports) {
            if (hasUnsentReports) {
                [FIRCrashlytics.crashlytics sendUnsentReports];
            } else {
                NSLog(@"No unsent reports");
            }

            UIAlertController* reportSender = [UIAlertController alertControllerWithTitle:@"Report Sent" message:@":-)" preferredStyle:UIAlertControllerStyleAlert];
            [reportSender addAction:[UIAlertAction actionWithTitle:@"Awesome" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
            [parent presentViewController:reportSender animated:YES completion:nil];
        }];
	});
}

- (void)sendTestEvent {
	[FIRAnalytics logEventWithName:@"test_sample_app_logging" parameters:@{
		@"launch_count" : [NSString stringWithFormat:@"%ld", (long)self.lastSessionLaunchCount]
	}];
}

@end
