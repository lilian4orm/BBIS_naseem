# Push Notification Testing Guide

## How to Test Notification Navigation

### 1. **Test Scenarios**

#### **When App is Closed (Terminated)**
- Close the app completely
- Send a push notification from Firebase Console or your server
- Tap the notification
- App should open directly to the specific screen based on notification type

#### **When App is in Background**
- Minimize the app (don't close it)
- Send a push notification
- Tap the notification
- App should come to foreground and navigate to the specific screen

### 2. **Notification Types and Expected Behavior**

#### **For Students (`account_type: "student"`)**
- `type: "notification"` → Opens `NotificationAll` page
- `type: "schedule"` → Opens `WeeklySchedule` page
- `type: "scheduleFood"` → Opens `FoodSchedule` page
- `type: "review"` → Opens `ReviewDate` page
- `type: "installments"` → Opens `StudentSalary` page
- `type: "message"` → Opens `ChatMain` page
- `type: "absence"` → Opens `StudentAttend` page
- `type: "news"` → Updates news data
- **Unknown type** → Opens `NotificationAll` page (fallback)

#### **For Teachers (`account_type: "teacher"`)**
- `type: "notification"` → Opens `NotificationTeacherAll` page
- `type: "schedule"` → Opens `TeacherWeeklySchedule` page
- `type: "message"` → Opens `ChatMain` page
- `type: "news"` → Updates news data
- **Unknown type** → Opens `NotificationTeacherAll` page (fallback)

#### **For Drivers (`account_type: "driver"`)**
- `type: "notification"` → Opens `NotificationByType` page with "تبليغ"
- **Unknown type** → Opens `NotificationByType` page with "تبليغ" (fallback)

#### **For Unauthenticated Users**
- Any notification → Redirects to `LoginPage`

### 3. **Testing with Firebase Console**

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and body
4. In "Additional options" → "Custom data", add:
   ```json
   {
     "type": "notification"
   }
   ```
5. Send to your app
6. Tap the notification when it arrives

### 4. **Testing with Server-Sent Notifications**

Send a POST request to FCM with this structure:
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "Test Notification",
    "body": "This is a test notification"
  },
  "data": {
    "type": "notification"
  }
}
```

### 5. **Key Changes Made**

1. **Fixed Navigation Issues:**
   - Changed `return const LoginPage();` to `Get.offAll(() => const LoginPage());`
   - This ensures proper navigation instead of just returning a widget

2. **Added Driver Support:**
   - Added proper handling for driver notifications
   - Imports the correct driver notification page

3. **Added Fallback Handling:**
   - Unknown notification types now redirect to the appropriate notifications page
   - Prevents the app from getting stuck

4. **Improved Code Structure:**
   - Better comments and organization
   - More robust error handling

### 6. **Troubleshooting**

If notifications still don't work as expected:

1. **Check Firebase Setup:**
   - Ensure `google-services.json` is properly configured
   - Verify FCM is enabled in Firebase Console

2. **Check Permissions:**
   - Android: Notification permissions should be granted
   - iOS: APNs certificates should be configured

3. **Check Logs:**
   - Look for `Logger().i()` output in console
   - Verify `message.data` contains the expected `type` field

4. **Test Different Scenarios:**
   - Test with app closed vs background
   - Test with different user types
   - Test with different notification types
