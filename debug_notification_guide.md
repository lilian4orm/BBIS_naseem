# دليل تشخيص مشكلة الإشعارات

## المشكلة الحالية
- العنوان "1" يظهر في الشريط العلوي ✅
- الوصف "2" لا يظهر في المحتوى ❌

## التحسينات المضافة للتشخيص

### 1. **تسجيل مفصل في Firebase Handler**
```dart
Logger().i('=== FIREBASE MESSAGE DEBUG ===');
Logger().i('message.data: ${message.data}');
Logger().i('message.notification: ${message.notification}');
Logger().i('message.notification?.title: ${message.notification?.title}');
Logger().i('message.notification?.body: ${message.notification?.body}');
Logger().i('message.data[title]: ${message.data['title']}');
Logger().i('message.data[body]: ${message.data['body']}');
Logger().i('message.data[type]: ${message.data['type']}');
```

### 2. **تسجيل في ShowMessage**
```dart
print('=== SHOWMESSAGE DEBUG ===');
print('widget.data: ${widget.data}');
print('notifications_title: ${widget.data['notifications_title']}');
print('notifications_description: ${widget.data['notifications_description']}');
```

### 3. **عرض تحذير مرئي**
إذا كان الوصف فارغ أو null، سيظهر مربع أحمر مع رسالة تشخيصية.

## خطوات التشخيص

### 1. **أرسل إشعار تجريبي:**
- العنوان: "1"
- الوصف: "2"

### 2. **تحقق من السجلات:**
ابحث في console/logs عن:
```
=== FIREBASE MESSAGE DEBUG ===
message.data: {...}
message.notification: {...}
```

### 3. **تحقق من البيانات في ShowMessage:**
ابحث عن:
```
=== SHOWMESSAGE DEBUG ===
widget.data: {...}
notifications_title: 1
notifications_description: 2
```

## الأسباب المحتملة

### 1. **مشكلة في إرسال البيانات من الخادم:**
- الخادم لا يرسل `body` في الإشعار
- البيانات تُرسل في `data` بدلاً من `notification`

### 2. **مشكلة في استقبال البيانات:**
- Firebase لا يستقبل البيانات بشكل صحيح
- البيانات تُفقد أثناء النقل

### 3. **مشكلة في معالجة البيانات:**
- البيانات تُستقبل لكن لا تُمرر بشكل صحيح لـ ShowMessage

## الحلول المقترحة

### 1. **إذا كانت البيانات تُرسل في `data` بدلاً من `notification`:**
```dart
final notificationTitle = message.data['title'] ?? message.notification?.title ?? 'إشعار';
final notificationBody = message.data['body'] ?? message.notification?.body ?? '';
```

### 2. **إذا كانت البيانات تُرسل بأسماء مختلفة:**
```dart
final notificationTitle = message.data['notifications_title'] ?? 
                         message.data['title'] ?? 
                         message.notification?.title ?? 'إشعار';
final notificationBody = message.data['notifications_description'] ?? 
                        message.data['body'] ?? 
                        message.notification?.body ?? '';
```

## كيفية الاختبار

### 1. **أرسل الإشعار:**
- افتح التطبيق
- أرسل إشعار مع العنوان "1" والوصف "2"

### 2. **تحقق من النتيجة:**
- يجب أن يظهر العنوان "1" في الشريط العلوي
- يجب أن يظهر الوصف "2" في المحتوى
- إذا لم يظهر الوصف، ستظهر رسالة تشخيصية حمراء

### 3. **تحقق من السجلات:**
- افتح console/logs
- ابحث عن رسائل التشخيص
- تأكد من أن البيانات تُستقبل بشكل صحيح

## النتيجة المتوقعة

بعد إضافة هذه التحسينات:
- ✅ **العنوان** سيظهر في الشريط العلوي
- ✅ **الوصف** سيظهر في المحتوى (أو رسالة تشخيصية إذا كان فارغاً)
- ✅ **السجلات** ستظهر البيانات المستلمة بالتفصيل
- ✅ **التشخيص** سيكون أسهل وأوضح
