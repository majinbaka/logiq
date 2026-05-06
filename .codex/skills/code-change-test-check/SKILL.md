---
name: code-change-test-check
description: Quy trình bắt buộc để xác thực lại sau mọi thay đổi code trong dự án Flutter. Dùng khi Codex vừa sửa code, fix bug, hoặc chuẩn bị chốt kết quả; yêu cầu chạy lại check/test theo thứ tự từ hẹp tới rộng, gồm flutter gen-l10n khi đổi ARB, flutter analyze, và flutter test phù hợp phạm vi thay đổi.
---

# Code Change Test Check

## Muc tieu
- Bat buoc co bang chung check/test truoc khi ket luan da fix.
- Chay kiem tra theo pham vi nho nhat truoc, sau do mo rong khi can.

## Quy trinh
1. Xac dinh pham vi thay doi:
- Liet ke file da sua va map vao feature/module lien quan.
- Neu co thay doi `lib/l10n/app_en.arb` hoac `lib/l10n/app_vi.arb`, danh dau can chay `flutter gen-l10n`.

2. Chay pre-check bat buoc:
- Khi ARB thay doi, chay:
```bash
flutter gen-l10n
```
- Luon chay:
```bash
flutter analyze
```

3. Chay test theo muc do anh huong:
- Uu tien test muc tieu truoc:
```bash
flutter test test/<target_file>.dart -r expanded
```
- Neu thay doi cham nhieu module hoac cham `core/`, `repositories/`, `bootstrap`, `storage`, chay full:
```bash
flutter test -r expanded
```

4. Xu ly khi test fail:
- Khong chot fix neu con fail.
- Sua theo root cause, sau do lap lai day du vong check.
- Neu test co nguy co treo/flaky, su dung timeout shell de co ket qua ro rang.

5. Bao cao ket qua:
- Ghi ro cac lenh da chay va trang thai pass/fail.
- Neu chua chay duoc full suite, neu ro pham vi da verify va rui ro con lai.

## Lenh mau voi timeout
```bash
timeout 120s flutter test test/<target_file>.dart -r expanded
timeout 600s flutter test -r expanded
```

## Dieu kien hoan tat
- `flutter analyze` pass.
- Tat ca test bat buoc theo pham vi thay doi pass.
- Khong con error moi do thay doi vua ap dung.
