String getFileExtension(String? type) {
  if(type == null) {
    return '';
  }else{
    return type.split('/').last;
  }
}
String getFileType(String? type) {
  if(type == null) {
    return '';
  }else{
    return type.split('/').first;
  }}
