---
name: smart-change-workflow
description: "Intelligent post-change control loop for this Flutter local-first trading diary project: classify impact from changed files, choose the right verification depth, enforce documentation and issue updates, and close with evidence. Use after any code, test, docs, storage, schema, l10n, or workflow change and before declaring a task done."
---

# Smart Change Workflow

## Muc tieu
- Giu moi thay doi di theo mot vong lap co bang chung: `scope -> verify -> docs -> report`.
- Giam regressions bang cach chay dung muc test theo muc do anh huong.
- Khong cho phep "done" neu thieu bang chung kiem tra.

## Quy trinh bat buoc
1. Xac dinh pham vi thay doi tu file da sua.
- Liet ke file da thay doi.
- Map file vao nhom anh huong theo [change-impact-matrix.md](references/change-impact-matrix.md).

2. Chon lane thuc thi.
- `docs-only`: chi doi tai lieu, khong doi logic runtime.
- `feature-ui`: doi view/viewmodel/widget trong `features/`.
- `domain-core`: doi `core/`, `repositories/`, `bootstrap`, `storage`, model.
- `l10n`: doi file `.arb` hoac string hien thi.
- `debug-fix`: dang sua issue fail/flaky/hang.

3. Thuc thi verify theo lane.
- Luon bat dau bang test hep nhat co y nghia.
- Nang cap scope khi cham nhieu module hoac cham `core/storage/repositories`.
- Neu lane `l10n`, chay `flutter gen-l10n` truoc `flutter analyze`.
- Neu test hang/flaky voi Hive lifecycle, dung skill `hive-test-stability`.

4. Cap nhat tai lieu va issue khi can.
- Neu doi behavior user: update `docs/FEATURES.md`.
- Neu doi schema/data semantics: update `docs/DATABASE_ERD.md`.
- Neu doi convention/quy tac: update `AGENTS.md`.
- Neu phat hien issue non-obvious:
  - Ghi `.github/investigation-notes/YYYY-MM-DD_<slug>.md`.
  - Cap nhat `.github/ISSUES.md`.

5. Chot ket qua bang bang chung.
- Bao cao ro cac lenh da chay va ket qua pass/fail.
- Neu chua chay full suite, neu ro rui ro con lai va ly do.
- Khong ket luan fix thanh cong neu con test fail hoac chua reproduce lai.

## Dieu phoi voi cac skill khac
- Dung `code-change-test-check` de thuc thi check/test sau khi sua code.
- Dung `issue-debug-playbook` khi can reproduce + khoanh vung root cause.
- Dung `hive-test-stability` khi test Hive bi treo/flaky teardown.
- Dung skill nay lam layer dieu phoi, khong thay the cac skill chuyen mon.

## Output template
Dung mau sau khi bao cao ket qua:

```text
Scope:
- <changed files + change type>

Verification:
- <command 1> -> <pass/fail>
- <command 2> -> <pass/fail>

Docs/Tracking:
- <updated docs/issues or "none">

Residual Risk:
- <none or explicit risk>
```

## Dieu kien hoan tat
- Da map thay doi vao dung lane.
- Da chay verify dung muc theo ma tran.
- Da cap nhat docs/issues bat buoc theo loai thay doi.
- Da co bao cao ket qua co bang chung command.
