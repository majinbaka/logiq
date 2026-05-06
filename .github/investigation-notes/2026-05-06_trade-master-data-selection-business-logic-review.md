# Trade Master Data Selection - Business Logic Review

- Date: 2026-05-06
- Scope: Luong tao Trade sau khi bo sung seed master data (Risk Rule templates + Strategy templates)

## User symptom

Nguoi dung phan hoi: "khi tao trade bi bat co san master data nhung lai khong chon duoc".

## What is implemented now

### 1) Strategy master data

- Form tao Trade cho phep chon `Strategy Version` qua dropdown.
- Nguon du lieu dropdown lay tu `TradesCrudViewModel.strategyVersionOptions`.
- Du lieu duoc load tu toan bo `Strategy` active + `StrategyVersion`:
  - `lib/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart` (`_loadStrategyVersionOptions`)
  - `lib/features/trades/presentation/widgets/components/trade_form_sheet.dart` (`DropdownButtonFormField<String?>` cho strategy)

Ket luan: Strategy master data la **co the chon duoc** trong form Trade theo thiet ke hien tai.

### 2) Risk rule master data

- Form tao Trade **khong co** truong chon `Risk Rule`.
- Risk Rule duoc dung de gate business flow (du dieu kien mo trade) thay vi cho user chon trong form.
- Kiem tra gate:
  - `missing_initial_deposit`
  - `missing_risk_rule`
  - trong `TradesCrudViewModel._assertTradeFlowReady`

Ket luan: Risk master data la **bat buoc ton tai** de tao trade, nhung **khong duoc chon truc tiep** trong UI tao trade.

## Root cause of confusion

Co mismatch giua expectation va implementation:

- Expectation tu user: da seed master data thi co the "chon" khi tao trade.
- Implementation hien tai:
  - Chi cho chon Strategy Version.
  - Risk Rule khong cho chon, chi check ton tai.

Vi vay user co cam giac "bi bat" ma "khong chon duoc".

## Important logic risk found

Trong `createTrade`, ham `_assertTradeFlowReady(accountId: accountId)` kiem tra account theo param `accountId`, nhung cac bien gate `_hasInitialDeposit` va `_activeRiskRule` lai duoc nap tu `activeAccountId` trong `_loadFlowState`.

- Evidence:
  - Load flow state theo `activeAccountId`: `TradesCrudViewModel._loadFlowState`
  - Validate create theo `accountId` param: `TradesCrudViewModel._assertTradeFlowReady`

Rui ro:

- Neu user doi account trong form Trade khac voi `activeAccountId`, ket qua gate co the sai account context.
- Co the dan den bao loi `missing_risk_rule`/`missing_initial_deposit` khong dung voi account dang chon.

## Business logic assessment

- Dung neu product decision la: Trade chi can 1 risk rule "applicable" tai thoi diem tao trade, khong can user chon rule cu the.
- Chua dung neu product decision la: user phai chon bo rule/template khi tao trade (vi hien tai khong co UI chon Risk Rule).

## Recommendation

1. Chot product rule ro rang:
- Option A: "Auto-apply risk rule" (khong cho chon trong form).
- Option B: "User must select risk rule" trong form tao trade.

2. Neu giu Option A, can sua logic gate theo account duoc chon trong form:
- tinh lai `hasInitialDeposit` + `activeRiskRule` theo `accountId` param ngay truoc khi validate.

3. Neu chuyen Option B, bo sung dropdown `Risk Rule` trong form Trade va luu `riskRuleId` vao du lieu lien quan (hoac risk_check).

4. Bo sung test cho truong hop multi-account:
- account A dat dieu kien, account B khong dat;
- doi account trong form va assert message gate dung account.

## Final conclusion

Phan seed master data da hoat dong, nhung trien khai hien tai tao ra trai nghiem khong ro rang:
- Strategy: co the chon.
- Risk Rule: bat buoc ton tai nhung khong cho chon.

Dong thoi co 1 diem can sua o logic validation context theo account de tranh false-negative khi tao Trade.
