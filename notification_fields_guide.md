# دليل الحقول المستخدمة في إرسال الإشعارات

## 📋 **الحقول الأساسية لإرسال الإشعار**

### 1. **الحقول المطلوبة (Required Fields):**

#### **notifications_title** - عنوان الإشعار
- **النوع:** String
- **الوصف:** العنوان الذي يظهر في الإشعار
- **مثال:** "إشعار مهم من المدرسة"

#### **notifications_type** - نوع الإشعار
- **النوع:** String
- **الوصف:** نوع الإشعار (يحدد كيفية معالجته)
- **القيم المتاحة:**
  - `"رسالة"` - رسالة عادية
  - `"واجب بيتي"` - واجب منزلي
  - `"امتحان يومي"` - امتحان يومي
  - `"تقرير"` - تقرير
  - `"تبليغ"` - تبليغ
  - `"ملخص"` - ملخص
  - `"البصمة"` - بصمة
  - `"الميلاد"` - عيد ميلاد

#### **notifications_student_id** - معرف الطلاب (اختياري)
- **النوع:** List<String>
- **الوصف:** قائمة معرفات الطلاب المستهدفين
- **مثال:** `["student_id_1", "student_id_2"]`

#### **notifications_class_school_id** - معرف الصفوف (اختياري)
- **النوع:** List<String>
- **الوصف:** قائمة معرفات الصفوف المستهدفة
- **مثال:** `["class_id_1", "class_id_2"]`

### 2. **الحقول الاختيارية (Optional Fields):**

#### **notifications_description** - وصف الإشعار
- **النوع:** String
- **الوصف:** المحتوى التفصيلي للإشعار
- **مثال:** "يرجى إحضار الكتب المطلوبة غداً"

#### **notifications_link** - رابط خارجي
- **النوع:** String
- **الوصف:** رابط لصفحة أو موقع خارجي
- **مثال:** "https://school.com/announcement/123"

#### **notifications_subject** - المادة الدراسية
- **النوع:** String
- **الوصف:** المادة الدراسية المرتبطة بالإشعار
- **مثال:** "الرياضيات", "اللغة العربية"

#### **photos** - الصور
- **النوع:** List<MultipartFile>
- **الوصف:** قائمة الصور المرفقة
- **تنسيق:** JPG, PNG
- **حد أقصى:** 10 صور

#### **pdf** - ملف PDF
- **النوع:** MultipartFile
- **الوصف:** ملف PDF مرفق
- **تنسيق:** PDF

#### **notifications_study_year** - السنة الدراسية
- **النوع:** String
- **الوصف:** السنة الدراسية الحالية
- **مثال:** "2024-2025"

## 🔧 **كيفية إرسال الإشعار**

### **1. إرسال إشعار بسيط:**
```dart
dio.FormData data = dio.FormData.fromMap({
  "notifications_type": "رسالة",
  "notifications_title": "عنوان الإشعار",
  "notifications_description": "وصف الإشعار",
  "notifications_study_year": "2024-2025",
});
```

### **2. إرسال إشعار مع صور:**
```dart
List<dio.MultipartFile> localPic = [];
for (int i = 0; i < _pic.length; i++) {
  localPic.add(dio.MultipartFile.fromFileSync(
    _pic[i].path,
    filename: 'pic$i.jpg',
    contentType: MediaType('image', 'jpg')
  ));
}

dio.FormData data = dio.FormData.fromMap({
  "notifications_type": "رسالة",
  "notifications_title": "عنوان الإشعار",
  "notifications_description": "وصف الإشعار",
  "photos": localPic,
  "notifications_study_year": "2024-2025",
});
```

### **3. إرسال إشعار مع PDF:**
```dart
dio.FormData data = dio.FormData.fromMap({
  "notifications_type": "تقرير",
  "notifications_title": "تقرير شهري",
  "notifications_description": "تقرير شهري للطلاب",
  "pdf": dio.MultipartFile.fromFileSync(
    _pdf!.path,
    filename: 'file.pdf',
    contentType: MediaType('application', 'pdf')
  ),
  "notifications_study_year": "2024-2025",
});
```

### **4. إرسال إشعار لطلاب محددين:**
```dart
dio.FormData data = dio.FormData.fromMap({
  "notifications_type": "واجب بيتي",
  "notifications_title": "واجب الرياضيات",
  "notifications_description": "حل التمارين من الصفحة 50",
  "notifications_student_id": ["student_id_1", "student_id_2"],
  "notifications_subject": "الرياضيات",
  "notifications_study_year": "2024-2025",
});
```

### **5. إرسال إشعار لصفوف محددة:**
```dart
dio.FormData data = dio.FormData.fromMap({
  "notifications_type": "تبليغ",
  "notifications_title": "إعلان مهم",
  "notifications_description": "اجتماع أولياء الأمور غداً",
  "notifications_class_school_id": ["class_id_1", "class_id_2"],
  "notifications_study_year": "2024-2025",
});
```

## 📱 **أنواع الإشعارات والتنقل**

### **للطلاب:**
- `"schedule"` → الجدول الأسبوعي
- `"scheduleFood"` → جدول الطعام
- `"review"` → مراجعة المواعيد
- `"installments"` → الأقساط
- `"message"` → الرسائل
- `"absence"` → الحضور والغياب
- `"news"` → تحديث الأخبار فقط
- **أي نوع آخر** → صفحة `ShowMessage`

### **للمعلمين:**
- `"schedule"` → الجدول الأسبوعي للمعلم
- `"message"` → الرسائل
- `"news"` → تحديث الأخبار فقط
- **أي نوع آخر** → صفحة `ShowMessage`

### **للسائقين:**
- **أي نوع** → صفحة `ShowMessage`

## 🔍 **التحقق من صحة البيانات**

### **قبل الإرسال:**
```dart
if (_receiver == '' || (_classes.isEmpty && _student.isEmpty)) {
  // يجب اختيار المستلمين
  EasyLoading.showError("Must select receivers");
} else if (_notificationType == '') {
  // يجب اختيار نوع الإشعار
  EasyLoading.showError("Must choose Notification type");
} else if (_formValidate.currentState!.validate()) {
  // إرسال الإشعار
  _send();
}
```

## 📊 **مثال كامل لإرسال إشعار**

```dart
_send() {
  if (_formValidate.currentState!.validate()) {
    List<dio.MultipartFile> localPic = [];
    for (int i = 0; i < _pic.length; i++) {
      localPic.add(dio.MultipartFile.fromFileSync(
        _pic[i].path,
        filename: 'pic$i.jpg',
        contentType: MediaType('image', 'jpg')
      ));
    }
    
    dio.FormData data = dio.FormData.fromMap({
      "notifications_student_id": _receiver == "الطلاب" ? _student : null,
      "notifications_class_school_id": _receiver == "الصفوف والشعب" ? _classes : null,
      "notifications_type": _notificationType,
      "notifications_title": _title.text,
      "notifications_description": _description.text.isEmpty ? null : _description.text,
      "notifications_link": _link.text.isEmpty ? null : _link.text,
      "notifications_subject": _notificationSubject != "" ? _notificationSubject : null,
      "photos": localPic.isEmpty ? null : localPic,
      "pdf": _pdf == null ? null : dio.MultipartFile.fromFileSync(
        _pdf!.path,
        filename: 'file.pdf',
        contentType: MediaType('application', 'pdf')
      ),
      "notifications_study_year": _mainDataProvider.mainData['setting'][0]['setting_year'],
    });
    
    NotificationsAPI().addNotification(data).then((res) {
      if (res['error'] == false) {
        _btnController.success();
        // نجح الإرسال
      } else {
        _btnController.error();
        // فشل الإرسال
      }
    });
  }
}
```

## 🎯 **ملاحظات مهمة**

1. **الحقول المطلوبة:** `notifications_type`, `notifications_title`
2. **اختيار المستلمين:** إما `notifications_student_id` أو `notifications_class_school_id`
3. **التحقق من الصحة:** يجب التحقق من صحة البيانات قبل الإرسال
4. **الملفات المرفقة:** الصور (JPG/PNG) و PDF مدعومة
5. **السنة الدراسية:** تُحصل تلقائياً من إعدادات النظام
