# اختبار عرض العنوان والوصف في الإشعارات

## التحقق من البيانات

### 1. **في السجلات (Logs)**
عند الضغط على الإشعار، يجب أن تظهر هذه السجلات:
```
I/flutter: Notification Title: [عنوان الإشعار]
I/flutter: Notification Description: [وصف الإشعار]
I/flutter: Full notification data: {_id: ..., notifications_title: ..., notifications_description: ...}
```

### 2. **في واجهة التطبيق**
- **العنوان** يظهر في شريط العنوان (AppBar)
- **الوصف** يظهر في المحتوى الرئيسي للصفحة

## كيفية اختبار الإشعارات

### 1. **إرسال إشعار من Firebase Console**
```json
{
  "notification": {
    "title": "عنوان الإشعار التجريبي",
    "body": "هذا وصف الإشعار التجريبي للاختبار"
  },
  "data": {
    "type": "notification"
  }
}
```

### 2. **إرسال إشعار من الخادم**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_TOKEN",
    "notification": {
      "title": "إشعار مهم",
      "body": "هذا إشعار مهم من المدرسة"
    },
    "data": {
      "type": "notification"
    }
  }'
```

### 3. **إرسال إشعار مع بيانات إضافية**
```json
{
  "notification": {
    "title": "عنوان من الإشعار",
    "body": "وصف من الإشعار"
  },
  "data": {
    "type": "notification",
    "title": "عنوان من البيانات",
    "body": "وصف من البيانات"
  }
}
```

## النتيجة المتوقعة

عند الضغط على الإشعار:

1. **يفتح `ShowMessage` مباشرة**
2. **يظهر العنوان في شريط العنوان**
3. **يظهر الوصف في المحتوى**
4. **تظهر السجلات في Console**

## استكشاف الأخطاء

### إذا لم يظهر العنوان أو الوصف:

1. **تحقق من السجلات:**
   - هل تظهر `Notification Title` و `Notification Description`؟
   - هل البيانات صحيحة؟

2. **تحقق من الإشعار المرسل:**
   - هل يحتوي على `title` و `body` في `notification`؟
   - أم في `data`؟

3. **تحقق من البيانات المرسلة:**
   - هل `message.notification?.title` موجود؟
   - أم `message.data['title']`؟

## أولوية البيانات

الكود يستخدم الأولوية التالية:
1. `message.notification?.title` (من Firebase notification)
2. `message.data['title']` (من البيانات المخصصة)
3. `'إشعار'` (افتراضي)

نفس الشيء للوصف:
1. `message.notification?.body`
2. `message.data['body']`
3. `''` (فارغ افتراضي)
