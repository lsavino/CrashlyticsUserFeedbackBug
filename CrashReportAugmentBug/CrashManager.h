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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashManager : NSObject

@property (readonly) NSInteger launchCount;
@property (readonly) BOOL didCrashOnPreviousLaunch;
@property (readonly) BOOL willAutoCrash;

+ (instancetype)sharedInstance;

- (void)setUpOnce;

- (void)incrementLaunchCount;
- (void)resetLaunchCount;

- (void)crashIfNeeded;

- (void)sendCrashReport;

- (void)sendTestEvent;

@end

NS_ASSUME_NONNULL_END
