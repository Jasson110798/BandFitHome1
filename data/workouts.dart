import '../models/exercise.dart';
import '../models/workout_plan.dart';

const workouts = <WorkoutPlan>[
  WorkoutPlan(
    name: 'Khởi động toàn thân',
    subtitle: 'Buổi tập nhẹ để làm quen với dây kháng lực',
    level: 'Cơ bản',
    durationLabel: '18–20 phút',
    focus: 'Toàn thân',
    exercises: [
      Exercise(name: 'Band Squat', muscle: 'Chân • Mông', band: 'Dây nhẹ', cue: 'Đạp gối theo hướng mũi chân, giữ lưng trung lập.', durationSec: 40, restSec: 20, emoji: '🏋️'),
      Exercise(name: 'Standing Row', muscle: 'Lưng', band: 'Dây nhẹ', cue: 'Kéo khuỷu tay về sau, siết hai bả vai.', durationSec: 40, restSec: 20, emoji: '🧲'),
      Exercise(name: 'Glute Kickback', muscle: 'Mông', band: 'Mini band', cue: 'Giữ hông thẳng, đá chân ra sau có kiểm soát.', durationSec: 35, restSec: 20, emoji: '🍑'),
      Exercise(name: 'Chest Press', muscle: 'Ngực • Tay sau', band: 'Dây nhẹ', cue: 'Neo dây chắc chắn, đẩy thẳng ra trước.', durationSec: 40, restSec: 20, emoji: '💪'),
      Exercise(name: 'Lateral Walk', muscle: 'Mông • Đùi ngoài', band: 'Mini band', cue: 'Hạ trọng tâm, bước ngang ngắn và đều.', durationSec: 35, restSec: 20, emoji: '↔️'),
      Exercise(name: 'Dead Bug Band', muscle: 'Core', band: 'Dây nhẹ', cue: 'Ép lưng dưới xuống sàn, di chuyển chậm.', durationSec: 35, restSec: 30, emoji: '🔥'),
    ],
  ),
  WorkoutPlan(
    name: 'Đốt năng lượng tại nhà',
    subtitle: 'Nhịp nhanh, ít nghỉ, phù hợp mục tiêu giảm mỡ',
    level: 'Trung bình',
    durationLabel: '24–28 phút',
    focus: 'Cardio + Toàn thân',
    exercises: [
      Exercise(name: 'Squat + Press', muscle: 'Toàn thân', band: 'Dây vừa', cue: 'Đứng lên đồng thời đẩy tay qua đầu.', durationSec: 45, restSec: 15, emoji: '⚡'),
      Exercise(name: 'Fast Band Row', muscle: 'Lưng • Tim mạch', band: 'Dây vừa', cue: 'Giữ thân ổn định, kéo nhanh nhưng kiểm soát.', durationSec: 45, restSec: 15, emoji: '🚣'),
      Exercise(name: 'Monster Walk', muscle: 'Mông • Đùi', band: 'Mini band', cue: 'Bước chéo tới trước, luôn giữ căng dây.', durationSec: 45, restSec: 15, emoji: '👣'),
      Exercise(name: 'Band Punch', muscle: 'Vai • Tay • Cardio', band: 'Dây nhẹ', cue: 'Đấm thẳng luân phiên, xoay thân nhẹ.', durationSec: 45, restSec: 15, emoji: '🥊'),
      Exercise(name: 'Romanian Deadlift', muscle: 'Đùi sau • Mông', band: 'Dây vừa', cue: 'Đẩy hông ra sau, lưng thẳng, siết mông khi đứng.', durationSec: 45, restSec: 20, emoji: '🦵'),
      Exercise(name: 'Standing Knee Drive', muscle: 'Core • Cardio', band: 'Mini band', cue: 'Kéo gối lên nhanh, giữ bụng chắc.', durationSec: 40, restSec: 20, emoji: '🔥'),
      Exercise(name: 'Biceps Curl', muscle: 'Tay trước', band: 'Dây vừa', cue: 'Giữ khuỷu tay sát thân, không đung đưa người.', durationSec: 40, restSec: 20, emoji: '💪'),
      Exercise(name: 'High Plank Band Tap', muscle: 'Core • Vai', band: 'Mini band', cue: 'Giữ hông ít xoay, chạm tay ra ngoài luân phiên.', durationSec: 35, restSec: 30, emoji: '🧱'),
    ],
  ),
  WorkoutPlan(
    name: 'Chân & mông săn chắc',
    subtitle: 'Tập trung thân dưới với mini band và dây dài',
    level: 'Trung bình',
    durationLabel: '22–25 phút',
    focus: 'Chân • Mông',
    exercises: [
      Exercise(name: 'Banded Squat', muscle: 'Đùi • Mông', band: 'Mini band', cue: 'Giữ gối mở nhẹ ra ngoài trong toàn bộ động tác.', durationSec: 45, restSec: 20, emoji: '🏋️'),
      Exercise(name: 'Hip Thrust', muscle: 'Mông', band: 'Mini band', cue: 'Đẩy hông lên, siết mông 1 giây ở đỉnh.', durationSec: 45, restSec: 20, emoji: '🍑'),
      Exercise(name: 'Reverse Lunge', muscle: 'Đùi • Mông', band: 'Dây nhẹ', cue: 'Bước lùi đủ xa, giữ thân người thẳng.', durationSec: 40, restSec: 20, emoji: '🦵'),
      Exercise(name: 'Lateral Walk', muscle: 'Đùi ngoài • Mông', band: 'Mini band', cue: 'Duy trì lực căng liên tục, không kéo lê chân.', durationSec: 40, restSec: 20, emoji: '↔️'),
      Exercise(name: 'Good Morning', muscle: 'Đùi sau • Lưng dưới', band: 'Dây vừa', cue: 'Gập từ hông, giữ cột sống trung lập.', durationSec: 40, restSec: 20, emoji: '🌅'),
      Exercise(name: 'Standing Abduction', muscle: 'Mông nhỡ', band: 'Mini band', cue: 'Đá chân sang bên mà không nghiêng thân.', durationSec: 35, restSec: 25, emoji: '🧘'),
    ],
  ),
  WorkoutPlan(
    name: 'Thân trên khỏe gọn',
    subtitle: 'Lưng, ngực, vai và cánh tay chỉ với dây dài',
    level: 'Cơ bản → Trung bình',
    durationLabel: '20–24 phút',
    focus: 'Thân trên',
    exercises: [
      Exercise(name: 'Seated Row', muscle: 'Lưng', band: 'Dây vừa', cue: 'Kéo về sát bụng, ngực mở, vai hạ thấp.', durationSec: 45, restSec: 20, emoji: '🚣'),
      Exercise(name: 'Chest Press', muscle: 'Ngực', band: 'Dây vừa', cue: 'Neo dây ngang ngực, đẩy thẳng và kiểm soát khi thu về.', durationSec: 45, restSec: 20, emoji: '🫸'),
      Exercise(name: 'Shoulder Press', muscle: 'Vai', band: 'Dây nhẹ', cue: 'Siết bụng, tránh ưỡn lưng khi đẩy qua đầu.', durationSec: 40, restSec: 20, emoji: '⬆️'),
      Exercise(name: 'Face Pull', muscle: 'Vai sau • Lưng trên', band: 'Dây nhẹ', cue: 'Kéo về ngang mặt, tách hai tay ra ngoài.', durationSec: 40, restSec: 20, emoji: '🎯'),
      Exercise(name: 'Biceps Curl', muscle: 'Tay trước', band: 'Dây vừa', cue: 'Chỉ gập khuỷu tay, giữ cổ tay thẳng.', durationSec: 40, restSec: 20, emoji: '💪'),
      Exercise(name: 'Triceps Extension', muscle: 'Tay sau', band: 'Dây nhẹ', cue: 'Giữ khuỷu tay cố định, duỗi thẳng cẳng tay.', durationSec: 40, restSec: 25, emoji: '🔱'),
    ],
  ),
];
