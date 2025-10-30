# فتح المحادثة الخاصة عند وصول رسالة من الدردشة

## 🎯 **المشكلة:**
تريد أن تفتح المحادثة الخاصة بين الطرفين عند وصول رسالة من الدردشة، وليس صفحة الدردشة العامة.

## ✅ **الحل المطبق:**

### **1. إضافة استخراج معلومات المرسل:**
```dart
// Extract sender info for chat
Map? senderInfo = message.data['sender_info'] != null ? 
  Map<String, dynamic>.from(message.data['sender_info']) : null;
```

### **2. إضافة imports لصفحات الدردشة الفردية:**
```dart
import 'package:BBInaseem/screens/student/dashboard_student/chat/chat_main/chat_page.dart'
    as student_chat;
import 'package:BBInaseem/screens/teacher/chat/chat_main/chat_page.dart'
    as teacher_chat;
```

### **3. تعديل منطق فتح الدردشة للطلاب:**
```dart
if (notificationType == 'message') {
  Logger().i('Opening chat for student');
  if (senderInfo != null) {
    // Open specific chat with sender
    Logger().i('Opening specific chat with sender: ${senderInfo['_id']}');
    Get.offAll(() => student_chat.ChatPage(
      userInfo: senderInfo,
      contentUrl: contentUrl,
      isChatOpen: true,
    ));
  } else {
    // Open general chat list
    Logger().i('Opening general chat list');
    Get.offAll(() => const student.ChatMain());
  }
  return;
}
```

### **4. تعديل منطق فتح الدردشة للمعلمين:**
```dart
if (notificationType == 'message') {
  Logger().i('Opening chat for teacher');
  if (senderInfo != null) {
    // Open specific chat with sender
    Logger().i('Opening specific chat with sender: ${senderInfo['_id']}');
    Get.offAll(() => teacher_chat.ChatPage(
      userInfo: senderInfo,
      contentUrl: contentUrl,
    ));
  } else {
    // Open general chat list
    Logger().i('Opening general chat list');
    Get.offAll(() => const teacher.ChatMain());
  }
  return;
}
```

## 📱 **كيفية إرسال رسالة دردشة مع معلومات المرسل:**

### **1. من Firebase Console:**
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
      "_id": "teacher_id_123",
      "account_name": "أحمد محمد",
      "account_img": "teacher_image.jpg",
      "account_type": "teacher"
    }
  }
}
```

### **2. من الخادم:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
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
        "_id": "teacher_id_123",
        "account_name": "أحمد محمد",
        "account_img": "teacher_image.jpg",
        "account_type": "teacher"
      }
    }
  }'
```

## 🎯 **النتيجة المتوقعة:**

### **عند إرسال رسالة مع `sender_info`:**
1. **يفتح المحادثة الخاصة** مع المرسل مباشرة ✅
2. **يظهر اسم المرسل** في شريط العنوان
3. **يظهر صورة المرسل** في المحادثة
4. **يتم تحميل الرسائل** بين الطرفين

### **عند إرسال رسالة بدون `sender_info`:**
1. **يفتح قائمة الدردشة العامة** ✅
2. **يمكن اختيار المحادثة** من القائمة

## 🔧 **معلومات المرسل المطلوبة:**

### **للطلاب (عند إرسال رسالة من معلم):**
```json
{
  "sender_info": {
    "_id": "teacher_id_123",
    "account_name": "أحمد محمد",
    "account_img": "teacher_image.jpg",
    "account_type": "teacher"
  }
}
```

### **للمعلمين (عند إرسال رسالة من طالب):**
```json
{
  "sender_info": {
    "_id": "student_id_456",
    "account_name": "سارة أحمد",
    "account_img": "student_image.jpg",
    "account_type": "student"
  }
}
```

## 📝 **السجلات المتوقعة:**

### **عند فتح المحادثة الخاصة:**
```
I/flutter: Notification Type: message
I/flutter: Is Message Type: true
I/flutter: Student notification, type: message
I/flutter: Opening chat for student
I/flutter: Opening specific chat with sender: teacher_id_123
[GETX] GOING TO ROUTE /ChatPage
```

### **عند فتح قائمة الدردشة:**
```
I/flutter: Notification Type: message
I/flutter: Is Message Type: true
I/flutter: Student notification, type: message
I/flutter: Opening chat for student
I/flutter: Opening general chat list
[GETX] GOING TO ROUTE /ChatMain
```

## 🎉 **النتيجة النهائية:**

### **عند وصول رسالة دردشة مع معلومات المرسل:**
1. **يفتح المحادثة الخاصة** مع المرسل مباشرة ✅
2. **يعمل مع جميع أنواع المستخدمين** (طلاب، معلمين)
3. **يعمل مع التطبيق المغلق والمفتوح**
4. **يظهر معلومات المرسل** في المحادثة

### **عند وصول رسالة دردشة بدون معلومات المرسل:**
1. **يفتح قائمة الدردشة العامة** ✅
2. **يمكن اختيار المحادثة** من القائمة

## 🚀 **الآن اختبر:**

1. **أرسل رسالة دردشة** مع `sender_info`
2. **أغلق التطبيق** تماماً
3. **اضغط على الإشعار**
4. **ستفتح المحادثة الخاصة** مع المرسل مباشرة

**الآن رسائل الدردشة تفتح المحادثة الخاصة بين الطرفين عند وصولها!** 🎉
