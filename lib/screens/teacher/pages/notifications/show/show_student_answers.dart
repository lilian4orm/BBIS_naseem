import 'package:cached_network_image/cached_network_image.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../api_connection/teacher/api_notification.dart';
import '../../../../../provider/teacher/provider_notification.dart';
import '../../../../../static_files/my_appbar.dart';
import '../../../../../static_files/my_loading.dart';
import 'homework_student_answer_show.dart';

class ShowStudentAnswers extends StatefulWidget {
  final Map data;
  const ShowStudentAnswers({Key? key, required this.data}) : super(key: key);

  @override
  State<ShowStudentAnswers> createState() => _ShowStudentAnswersState();
}

class _ShowStudentAnswersState extends State<ShowStudentAnswers> {
  int page =0;
  getAnswers(){
    NotificationsAPI().getHomeworkAnswers(widget.data['_id'],page);
  }
  @override
  void initState() {
    getAnswers();
    super.initState();
  }

  @override
  void dispose() {
    Get.put(TeacherHomeworkAnswersProvider()).remove();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("اجوبة الواجب البيتي"),
      body: GetBuilder<TeacherHomeworkAnswersProvider>(
        builder: (val) {
          return val.isLoading
              ? loading()
              : val.data.isEmpty
              ? Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
                child: Center(
                  child: EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_3,
                      title: 'لاتوجد اجوبة',
                      subTitle: 'لم يتم اضافة اي اجابة بعد',
                      titleTextStyle: const TextStyle(
                        fontSize: 22,
                        color: Color(0xff9da9c7),
                        fontWeight: FontWeight.w500,
                      ),
                      subtitleTextStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffabb8d6),
                      ),
                    ),
                ),
              )
              : ListView.separated(
                  itemCount: val.data.length,
                  itemBuilder: (context,index){
                    return ListTile(
                      title: Text(val.data[index]['homework_answers_student']['account_name'],style: const TextStyle(fontSize: 15,),maxLines: 1,),
                      leading: _profileImg(val.contentUrl , val.data[index]['homework_answers_student']['account_img']),
                      subtitle: Text(val.data[index]['homework_answers_text'],style: const TextStyle(fontSize: 13,),maxLines: 3),
                      onTap: (){
                        Get.to(()=> HomeworkStudentAnswerShow(data: val.data[index],contentUrl: val.contentUrl,));
                      },
                      //subtitle: Text(val.data[index]['homework_answers_student']['account_division_current']['class_name']+' - '+val.data[index]['homework_answers_student']['account_division_current']['leader']),
                    );
                  },
                  separatorBuilder: (context,index){
                    return const Divider();
                  },
              );
        }
      ),
    );
  }
}

Widget _profileImg(String contentUrl,String? img){
  if(img==null){
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset("assets/img/ايكونه تطبيق2 (2).png",fit: BoxFit.cover),
      ),
    );
  }else{
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CachedNetworkImage(
          imageUrl: contentUrl + img,
          fit: BoxFit.cover,
          placeholder: (context, url) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
            ],
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}