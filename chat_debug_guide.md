# دليل تشخيص مشكلة فتح المحادثة

## 🔍 **التشخيص المحسن:**

تم إضافة تسجيل مفصل لمعرفة سبب المشكلة:

### **1. تسجيل معلومات المرسل:**
```
I/flutter: Sender Info: {_id: teacher_123, account_name: أحمد محمد, ...}
I/flutter: Sender Info Type: _Map<String, dynamic>
```

### **2. تسجيل منطق فتح الدردشة:**
```
I/flutter: Student notification, type: message
I/flutter: Opening chat for student
I/flutter: Sender Info is null: false
I/flutter: Opening specific chat with sender: teacher_123
I/flutter: Sender Info Keys: [_id, account_name, account_img, account_type]
I/flutter: Successfully opened specific chat
```

### **3. تسجيل الأخطاء:**
```
I/flutter: Error opening specific chat: [error details]
```

## 📱 **خطوات التشخيص:**

### **1. أرسل إشعار تجريبي:**
```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "رسالة جديدة",
    "body": "لديك رسالة جديدة من المعلم"
  },
  "data": {
    "type": "message",
    "notifications_title": "رسالة جديدة",
    "notifications_description": "لديك رسالة جديدة من المعلم",
    "sender_info": {
      "_id": "teacher_123",
      "account_name": "أحمد محمد",
      "account_img": "teacher_image.jpg",
      "account_type": "teacher"
    }
  }
}
```

### **2. تحقق من السجلات:**
ابحث عن هذه الرسائل في السجلات:

#### **إذا كان `type` صحيح:**
```
I/flutter: Notification Type: message
I/flutter: Is Message Type: true
I/flutter: Student notification, type: message
I/flutter: Opening chat for student
```

#### **إذا كانت معلومات المرسل متوفرة:**
```
I/flutter: Sender Info: {_id: teacher_123, account_name: أحمد محمد, ...}
I/flutter: Sender Info is null: false
I/flutter: Opening specific chat with sender: teacher_123
I/flutter: Successfully opened specific chat
```

#### **إذا لم تكن معلومات المرسل متوفرة:**
```
I/flutter: Sender Info: null
I/flutter: Sender Info is null: true
I/flutter: Opening general chat list
```

## 🎯 **الأسباب المحتملة للمشكلة:**

### **1. `type` ليس "message":**
```
I/flutter: Notification Type: null
I/flutter: Is Message Type: false
```
**الحل:** تأكد من إرسال `"type": "message"` في `data`

### **2. معلومات المرسل غير متوفرة:**
```
I/flutter: Sender Info: null
I/flutter: Sender Info is null: true
```
**الحل:** أضف `sender_info` في `data`

### **3. خطأ في فتح المحادثة:**
```
I/flutter: Error opening specific chat: [error details]
```
**الحل:** تحقق من صحة بيانات `sender_info`

### **4. يفتح ShowMessage بدلاً من المحادثة:**
```
I/flutter: Opening ShowMessage for student
```
**الحل:** تأكد من أن `type` هو "message" وليس "notification"

## 🔧 **الحلول المقترحة:**

### **1. إذا كان `type` فارغ:**
```json
{
  "data": {
    "type": "message"  // ← تأكد من وجود هذا
  }
}
```

### **2. إذا كانت معلومات المرسل فارغة:**
```json
{
  "data": {
    "sender_info": {
      "_id": "teacher_123",
      "account_name": "أحمد محمد",
      "account_img": "teacher_image.jpg",
      "account_type": "teacher"
    }
  }
}
```

### **3. إذا كان هناك خطأ في المحادثة:**
تحقق من أن `sender_info` يحتوي على:
- `_id` (معرف المرسل)
- `account_name` (اسم المرسل)
- `account_img` (صورة المرسل)
- `account_type` (نوع الحساب)

## 📝 **مثال كامل للإرسال الصحيح:**

```json
{
  "to": "DEVICE_TOKEN",
  "notification": {
    "title": "رسالة جديدة",
    "body": "لديك رسالة جديدة من المعلم"
  },
  "data": {
    "type": "message",
    "notifications_title": "رسالة جديدة",
    "notifications_description": "لديك رسالة جديدة من المعلم",
    "sender_info": {
      "_id": "teacher_123",
      "account_name": "أحمد محمد",
      "account_img": "teacher_image.jpg",
      "account_type": "teacher"
    }
  }
}
```

## 🚀 **الآن اختبر وأرسل السجلات:**

1. **أرسل الإشعار** مع البيانات الصحيحة
2. **انسخ السجلات** من console/logs
3. **أرسل السجلات** ليتمكن من التشخيص

**مع التسجيل المفصل، يمكننا تحديد المشكلة بدقة!** 🔍
