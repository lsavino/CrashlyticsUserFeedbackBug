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

	[FIRCrashlytics.crashlytics setCustomValue:NSDate.date forKey:@"initial_crash_key"];

	[FIRCrashlytics.crashlytics log:@"test log"];
}

- (NSString*)userID {
    NSUUID *deviceID = UIDevice.currentDevice.identifierForVendor;
    NSString *uuidString = deviceID.UUIDString;
    NSRange range = NSMakeRange(0, 5);
    return [uuidString substringWithRange:range];
}

- (void)incrementLaunchCount {
	[[NSUserDefaults standardUserDefaults] setInteger:self.launchCount + 1 forKey:kLaunchCountKey];
}

- (void)resetLaunchCount {
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kLaunchCountKey];
}

- (NSInteger)launchCount {
	return [[NSUserDefaults standardUserDefaults] integerForKey:kLaunchCountKey];
}

- (BOOL)didCrashOnPreviousLaunch {
	return [[FIRCrashlytics crashlytics] didCrashDuringPreviousExecution];
}

- (void)crashWithType:(CrashType)type {
	switch (type) {
		case CrashTypeAssertion:
            assert(false);
			break;

		case CrashTypeBadIndex: {
            NSArray* items = @[@"a"];
            NSString* i = items[42];
            NSLog(@"Crashed with %@", i);
        } break;
	}
}

- (void)sendCrashReport {
    [FIRCrashlytics.crashlytics setCustomValue:NSDate.date forKey:@"crash_reported_timestamp"];

	[FIRCrashlytics.crashlytics checkForUnsentReportsWithCompletion:^(BOOL hasUnsentReports) {
		if (hasUnsentReports) {
			[FIRCrashlytics.crashlytics setCustomValue:@(self.launchCount) forKey:@"crash_associated_launch_count"];
			[FIRCrashlytics.crashlytics sendUnsentReports];
		} else {
			NSLog(@"No unsent reports");
		}
	}];
}

- (void)sendTestEvent {
	[FIRAnalytics logEventWithName:@"test_sample_app_logging" parameters:@{
		@"launch_count" : [NSString stringWithFormat:@"%ld", (long)self.launchCount]
	}];
}

@end
