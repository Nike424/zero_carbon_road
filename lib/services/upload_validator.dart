class UploadValidator {
  static final Map<String, List<String>> keywords = {
    '绿色出行': ['步行', '公交', '地铁', '骑行', '自行车', '电动车', '新能源', '不开车', '拼车', '走路'],
    '低碳饮食': ['素食', '蔬菜', '水果', '本地', '当季', '减少红肉', '少吃肉', '光盘', '打包'],
    '垃圾分类': ['回收', '分类', '塑料', '纸张', '玻璃', '金属', '电池', '垃圾'],
    '节约能源': ['关灯', '节能', '拔插头', '空调26度', '省电', '省水', '水循环'],
    '绿色消费': ['环保袋', '自带杯', '拒绝一次性', '二手', '租赁', '修理'],
    '植树造林': ['植树', '种树', '绿化', '森林', '碳汇'],
  };

  static ValidationResult validate(String type, String description) {
    final descLower = description.toLowerCase();
    final requiredKeywords = keywords[type] ?? [];
    if (requiredKeywords.isEmpty) return ValidationResult(valid: true);

    for (final kw in requiredKeywords) {
      if (descLower.contains(kw.toLowerCase())) {
        return ValidationResult(valid: true);
      }
    }
    return ValidationResult(
      valid: false,
      message: '描述必须包含与“$type”相关的内容，如：${requiredKeywords.take(3).join('、')}等',
    );
  }
}

class ValidationResult {
  final bool valid;
  final String? message;
  ValidationResult({required this.valid, this.message});
}
