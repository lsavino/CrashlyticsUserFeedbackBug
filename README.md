The intent of this repo is to demonstrate a bug in the Firebase SDK for iOS. This bug was not present in the 6.13.0 version of the SDK. It appeared no later than version 6.28.0, and continues through at least 6.33.0.

The gist of the issue is that we try to collect user feedback/permissions when a crash is detected. However, this feedback is added to the _next_ crash that happens, instead of the one that is about to be reported.

This sample app keeps a running tally of its launch count. The best way to crash is by clicking the "bad index" button, wherein the app will try to index into an empty array with the current launch count. On launch, we save this same number to a preference so it can be read by the next app session. During the next app session, that number is pulled from the preferences and attached to the outgoing crash report via the `setCustomValue` API. This is intended to represent the user's feedback regarding the prior session (hence the "old" launch count value). So in a well-functioning world, the crash report should have a "bad index" crash, and a "feedback" custom value, and both of these launch count values should be the same. The current behavior we are seeing is the feedback value and the bad index value are off by one.
