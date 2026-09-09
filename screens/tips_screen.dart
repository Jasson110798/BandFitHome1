import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      ('🪢', 'Kiểm tra dây trước khi tập', 'Không dùng dây bị nứt, rách hoặc giòn. Đảm bảo điểm neo chắc chắn trước các động tác kéo/đẩy.'),
      ('🎚️', 'Chọn lực cản vừa sức', 'Bạn nên hoàn thành được thời gian tập với kỹ thuật ổn định. Nếu phải giật người để kéo dây, lực cản đang quá cao.'),
      ('🧍', 'Ưu tiên kỹ thuật', 'Giữ cột sống trung lập, kiểm soát nhịp đi và nhịp về. Không cần tập nhanh nếu động tác mất kiểm soát.'),
      ('📅', 'Duy trì đều đặn', 'Có thể bắt đầu 3–4 buổi/tuần, xen kẽ ngày nhẹ hoặc nghỉ để cơ thể hồi phục.'),
      ('🥗', 'Kết hợp ăn uống hợp lý', 'Mục tiêu giảm cân bền vững cần cân bằng tổng năng lượng, protein, rau quả, nước và giấc ngủ.'),
      ('🛑', 'Dừng khi có dấu hiệu bất thường', 'Nếu đau nhói, chóng mặt, khó thở bất thường hoặc khó chịu kéo dài, hãy dừng tập và cân nhắc trao đổi với chuyên gia y tế.'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
        children: [
          Text('Hướng dẫn', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Tập an toàn và bền vững quan trọng hơn tập thật nặng.'),
          const SizedBox(height: 20),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.$1, style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tip.$2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(tip.$3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
