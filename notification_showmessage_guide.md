# دليل إرسال الإشعارات لفتح ShowMessage

## التغييرات المنجزة

تم تعديل معالجة الإشعارات لفتح صفحة `ShowMessage` بدلاً من صفحات الإشعارات العامة.

## كيفية إرسال الإشعارات

### 1. **إرسال إشعار بسيط (يفتح ShowMessage)**

```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "عنوان الإشعار",
    "body": "محتوى الإشعار"
  },
  "data": {
    "type": "notification"
  }
}
```

### 2. **إشعار مع بيانات إضافية**

```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "عنوان الإشعار",
    "body": "محتوى الإشعار"
  },
  "data": {
    "type": "notification",
    "id": "unique_notification_id",
    "title": "عنوان الإشعار (اختياري)",
    "body": "محتوى الإشعار (اختياري)",
    "link": "https://example.com",
    "images": "image_url1,image_url2",
    "sender": "اسم المرسل",
    "content_url": "https://api.example.com/content"
  }
}
```

### 3. **أنواع الإشعارات الخاصة**

#### للطلاب:
- `type: "schedule"` → يفتح الجدول الأسبوعي
- `type: "scheduleFood"` → يفتح جدول الطعام
- `type: "review"` → يفتح مراجعة المواعيد
- `type: "installments"` → يفتح صفحة الأقساط
- `type: "message"` → يفتح صفحة الرسائل
- `type: "absence"` → يفتح صفحة الحضور
- `type: "news"` → يحدث الأخبار فقط
- **أي نوع آخر** → يفتح `ShowMessage`

#### للمعلمين:
- `type: "schedule"` → يفتح الجدول الأسبوعي للمعلم
- `type: "message"` → يفتح صفحة الرسائل
- `type: "news"` → يحدث الأخبار فقط
- **أي نوع آخر** → يفتح `ShowMessage`

#### للسائقين:
- **أي نوع** → يفتح `ShowMessage`

## البيانات المطلوبة لـ ShowMessage

```dart
Map notificationData = {
  '_id': 'معرف فريد للإشعار',
  'notifications_title': 'عنوان الإشعار',
  'notifications_description': 'وصف الإشعار',
  'notifications_type': 'نوع الإشعار',
  'notifications_link': 'رابط اختياري',
  'notifications_imgs': 'صور اختيارية',
  'notifications_sender': 'بيانات المرسل',
  'created_at': 'وقت الإنشاء',
  'isRead': false,
};
```

## مثال كامل لإرسال إشعار

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_TOKEN",
    "notification": {
      "title": "إشعار جديد",
      "body": "لديك إشعار جديد من المدرسة"
    },
    "data": {
      "type": "notification",
      "id": "notif_12345",
      "link": "https://school.com/announcement/123",
      "sender": "إدارة المدرسة"
    }
  }'
```

## النتيجة المتوقعة

عند الضغط على الإشعار:
- ✅ **إذا كان التطبيق مغلقاً:** يفتح مباشرة على `ShowMessage`
- ✅ **إذا كان التطبيق في الخلفية:** ينتقل مباشرة إلى `ShowMessage`
- ✅ **يظهر في السجلات:** `[GETX] GOING TO ROUTE /ShowMessage`

## ملاحظات مهمة

1. **إذا لم يتم تحديد `type`:** سيتم فتح `ShowMessage` بشكل افتراضي
2. **إذا كانت البيانات فارغة:** سيتم إنشاء بيانات افتراضية
3. **الأنواع الخاصة:** بعض الأنواع مثل `schedule` و `message` تفتح صفحات محددة
4. **الأنواع العامة:** أي نوع آخر يفتح `ShowMessage`

## اختبار الإشعارات

1. أرسل إشعار من Firebase Console أو من الخادم
2. تأكد من وجود `type` في `data`
3. اضغط على الإشعار
4. يجب أن يفتح `ShowMessage` مباشرة
