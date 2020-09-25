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

#import "CrashManager.h"

#import "Firebase.h"

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

	[FIRCrashlytics.crashlytics setCustomValue:@"test value" forKey:@"initial_crash_key"];
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

- (BOOL)willAutoCrash {
	return self.launchCount % 2 == 1;
}

- (BOOL)didCrashOnPreviousLaunch {
	return [[FIRCrashlytics crashlytics] didCrashDuringPreviousExecution];
}

- (void)crashWithType:(CrashType)type {
	switch (type) {
		case CrashTypeAlways:
			[self crashWithDelay:0];
			break;

		case CrashTypeConditional:
			if ([self willAutoCrash]) {
				[self crashWithDelay:3];
			}
			break;
	}
}

- (void)crashWithDelay:(NSTimeInterval)delay {

	NSInteger crashIndex = self.launchCount;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSArray* items = @[@"a"];
		NSString* i = items[crashIndex];
		NSLog(@"Crashed with %@", i);
	});
}

- (void)sendCrashReport {

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
