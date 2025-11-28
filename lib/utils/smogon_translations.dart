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
const Map<String, String> abilityTranslations = {
  'Intimidate': '威吓', 'Levitate': '漂浮', 'Flash Fire': '引火',
  'Pressure': '压迫感', 'Static': '静电', 'Sturdy': '结实',
  'Blaze': '猛火', 'Torrent': '激流', 'Overgrow': '茂盛',
  'Swarm': '虫之预感', 'Guts': '毅力', 'Keen Eye': '锐利目光',
  'Inner Focus': '精神力', 'Synchronize': '同步', 'Trace': '复制',
  'Sand Stream': '扬沙', 'Drizzle': '降雨', 'Drought': '日照',
  'Snow Warning': '降雪', 'Speed Boost': '加速', 'Multiscale': '多重鳞片',
  'Technician': '技术高手', 'Scrappy': '胆量', 'Mold Breaker': '破格',
  'Prankster': '恶作剧之心', 'Beast Boost': '异兽提升', 'Protosynthesis': '古代活性',
  'Quark Drive': '夸克充能', 'Supreme Overlord': '大将', 'Purifying Salt': '洁净之盐',
};

// 常用招式 (示例 - 数量巨大，仅列举极少部分)
const Map<String, String> moveTranslations = {
  'Protect': '守住', 'Substitute': '替身', 'Rest': '睡觉', 'Sleep Talk': '梦话',
  'Toxic': '剧毒', 'Thunder Wave': '电磁波', 'Will-O-Wisp': '鬼火',
  'Stealth Rock': '隐形岩', 'Spikes': '撒菱', 'Defog': '清除浓雾',
  'Rapid Spin': '高速旋转', 'Roost': '羽栖', 'Recover': '自我再生',
  'Synthesis': '光合作用', 'Moonlight': '月光', 'Morning Sun': '晨光',
  'Wish': '祈愿', 'Healing Wish': '治愈之愿', 'Teleport': '瞬间移动',
  'U-turn': '急速折返', 'Volt Switch': '伏特替换', 'Flip Turn': '快速折返',
  'Knock Off': '拍落', 'Earthquake': '地震', 'Scald': '热水',
  'Surf': '冲浪', 'Hydro Pump': '水炮', 'Flamethrower': '喷射火焰',
  'Fire Blast': '大字爆炎', 'Ice Beam': '冰冻光束', 'Blizzard': '暴风雪',
  'Thunderbolt': '十万伏特', 'Thunder': '打雷', 'Psychic': '精神强念',
  'Shadow Ball': '暗影球', 'Sludge Bomb': '污泥炸弹', 'Dazzling Gleam': '魔法闪耀',
  'Moonblast': '月亮之力', 'Close Combat': '近身战', 'Superpower': '蛮力',
  'Brave Bird': '勇鸟猛攻', 'Acrobatics': '杂技', 'Stone Edge': '尖石攻击',
  'Rock Slide': '岩崩', 'Iron Head': '铁头', 'Flash Cannon': '加农光炮',
  'Draco Meteor': '流星群', 'Outrage': '逆鳞', 'Dragon Claw': '龙爪',
  'Play Rough': '嬉闹', 'Leaf Storm': '飞叶风暴', 'Giga Drain': '终极吸取',
  'Power Whip': '强力鞭打', 'Solar Beam': '日光束', 'Hurricane': '暴风',
  'Focus Blast': '真气弹', 'Aura Sphere': '波导弹', 'Dark Pulse': '恶之波动',
  'Sucker Punch': '突袭', 'Pursuit': '追打', 'Shadow Sneak': '影子偷袭',
  'Aqua Jet': '水流喷射', 'Ice Shard': '冰砾', 'Bullet Punch': '子弹拳',
  'Mach Punch': '音速拳', 'Vacuum Wave': '真空波', 'Quick Attack': '电光一闪',
  'Extreme Speed': '神速', 'Fake Out': '击掌奇袭', 'Encore': '再来一次',
  'Taunt': '挑衅', 'Torment': '无理取闹', 'Disable': '定身法',
  'Calm Mind': '冥想', 'Nasty Plot': '诡计', 'Swords Dance': '剑舞',
  'Dragon Dance': '龙之舞', 'Bulk Up': '健美', 'Curse': '诅咒',
  'Agility': '高速移动', 'Rock Polish': '岩石打磨', 'Shell Smash': '破壳',
  'Belly Drum': '腹鼓', 'Trick Room': '戏法空间', 'Tailwind': '顺风',
  'Light Screen': '光墙', 'Reflect': '反射壁', 'Aurora Veil': '极光幕',
  'Baton Pass': '接棒', 'Haze': '黑雾', 'Whirlwind': '吹飞',
  'Roar': '吼叫', 'Dragon Tail': '龙尾', 'Circle Throw': '巴投',
  'Perish Song': '灭亡之歌', 'Destiny Bond': '同命', 'Explosion': '大爆炸',
  'Self-Destruct': '自爆', 'Memento': '临别礼物', 'Yawn': '哈欠',
  'Leech Seed': '寄生种子', 'Pain Split': '分担痛楚', 'Endeavor': '蛮干',
  'Super Fang': '愤怒门牙', 'Seismic Toss': '地球上投', 'Night Shade': '黑夜魔影',
  'Foul Play': '欺诈', 'Body Press': '扑击', 'Stored Power': '辅助力量',
  'Tera Blast': '太晶爆发',
};
