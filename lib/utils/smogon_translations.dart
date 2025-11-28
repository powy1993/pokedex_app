import 'move_data.dart';
import 'ability_data.dart';

const Map<String, String> natureTranslations = {
  'Hardy': '勤奋', 'Lonely': '怕寂寞', 'Brave': '勇敢', 'Adamant': '固执', 'Naughty': '顽皮',
  'Bold': '大胆', 'Docile': '坦率', 'Relaxed': '悠闲', 'Impish': '淘气', 'Lax': '乐天',
  'Timid': '胆小', 'Hasty': '急躁', 'Serious': '认真', 'Jolly': '爽朗', 'Naive': '天真',
  'Modest': '内敛', 'Mild': '慢吞吞', 'Quiet': '冷静', 'Bashful': '害羞', 'Rash': '马虎',
  'Calm': '温和', 'Gentle': '温顺', 'Sassy': '自大', 'Careful': '慎重', 'Quirky': '浮躁',
};

const Map<String, String> natureModifiers = {
  'Hardy': '', 'Lonely': '(+攻击, -防御)', 'Brave': '(+攻击, -速度)', 'Adamant': '(+攻击, -特攻)', 'Naughty': '(+攻击, -特防)',
  'Bold': '(+防御, -攻击)', 'Docile': '', 'Relaxed': '(+防御, -速度)', 'Impish': '(+防御, -特攻)', 'Lax': '(+防御, -特防)',
  'Timid': '(+速度, -攻击)', 'Hasty': '(+速度, -防御)', 'Serious': '', 'Jolly': '(+速度, -特攻)', 'Naive': '(+速度, -特防)',
  'Modest': '(+特攻, -攻击)', 'Mild': '(+特攻, -防御)', 'Quiet': '(+特攻, -速度)', 'Bashful': '', 'Rash': '(+特攻, -特防)',
  'Calm': '(+特防, -攻击)', 'Gentle': '(+特防, -防御)', 'Sassy': '(+特防, -速度)', 'Careful': '(+特防, -特攻)', 'Quirky': '',
};

const Map<String, String> smogonStatTranslations = {
  'hp': 'HP', 'atk': '攻击', 'def': '防御', 'spa': '特攻', 'spd': '特防', 'spe': '速度',
};

// 常用竞技道具 (示例)
const Map<String, String> itemTranslations = {
  'Leftovers': '吃剩的东西', 'Life Orb': '生命宝珠', 'Choice Scarf': '讲究围巾',
  'Choice Band': '讲究头带', 'Choice Specs': '讲究眼镜', 'Heavy-Duty Boots': '厚底靴',
  'Rocky Helmet': '凸凸头盔', 'Assault Vest': '突击背心', 'Focus Sash': '气势披带',
  'Sitrus Berry': '文柚果', 'Black Sludge': '黑色污泥', 'Eviolite': '进化奇石',
  'Expert Belt': '达人带', 'Weakness Policy': '弱点保险', 'Flame Orb': '火焰宝珠',
  'Toxic Orb': '剧毒宝珠', 'Light Clay': '光之黏土', 'Mental Herb': '心灵香草',
  'Power Herb': '强力香草', 'White Herb': '白色香草', 'Red Card': '红牌',
  'Eject Button': '逃脱按键', 'Eject Pack': '避难背包', 'Throat Spray': '喉咙喷雾',
  'Booster Energy': '驱劲能量', 'Clear Amulet': '清净坠饰', 'Covert Cloak': '密探斗篷',
  'Loaded Dice': '机变骰子', 'Punching Glove': '拳击手套',
};

// 常用特性 (示例)
const Map<String, String> abilityTranslations = abilityNameTranslations;

// 招式翻译 (来自 52poke Wiki)
const Map<String, String> moveTranslations = moveNameTranslations;
