// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Trading Diary';

  @override
  String get navTrades => 'Giao dịch';

  @override
  String get navPortfolio => 'Danh mục';

  @override
  String get navStrategy => 'Chiến lược';

  @override
  String get navJournal => 'Nhật ký';

  @override
  String get navPsychology => 'Tâm lý';

  @override
  String get navInsights => 'Nhận định';

  @override
  String get workInProgressTitle => 'Đang phát triển';

  @override
  String get tradesCrudTitle => 'Giao dịch';

  @override
  String get tradesCrudSubtitle => 'Tạo, cập nhật và xóa lệnh trong nhật ký giao dịch.';

  @override
  String get tradesLoadErrorTitle => 'Không thể tải giao dịch';

  @override
  String get tradesLoadErrorBody => 'Vui lòng thử tải lại danh sách giao dịch.';

  @override
  String get tradesRetry => 'Thử lại';

  @override
  String get tradesEmptyTitle => 'Chưa có giao dịch';

  @override
  String get tradesEmptyBody => 'Nhấn Thêm giao dịch để tạo lệnh đầu tiên.';

  @override
  String get tradesAddButton => 'Thêm giao dịch';

  @override
  String get tradesCreateTitle => 'Tạo giao dịch';

  @override
  String get tradesEditTitle => 'Sửa giao dịch';

  @override
  String get tradesDetailTitle => 'Chi tiết giao dịch';

  @override
  String get tradesAccountLabel => 'Tài khoản';

  @override
  String get tradesInstrumentLabel => 'Mã instrument';

  @override
  String get tradesDirectionLabel => 'Chiều lệnh';

  @override
  String get tradesDirectionBuy => 'BUY';

  @override
  String get tradesDirectionSell => 'SELL';

  @override
  String get tradesStatusLabel => 'Trạng thái';

  @override
  String get tradesStatusOpen => 'Mở';

  @override
  String get tradesStatusClosed => 'Đóng';

  @override
  String get tradesStatusDraft => 'Nháp';

  @override
  String get tradesOpenedAtLabel => 'Ngày mở lệnh';

  @override
  String get tradesOpenedAtHint => 'YYYY-MM-DD';

  @override
  String get tradesQuantityLabel => 'Khối lượng';

  @override
  String get tradesEntryPriceLabel => 'Giá vào';

  @override
  String get tradesExitPriceLabel => 'Giá ra';

  @override
  String get tradesFeeLabel => 'Phí';

  @override
  String get tradesTaxLabel => 'Thuế';

  @override
  String get tradesPlanLabel => 'Kế hoạch';

  @override
  String get tradesReviewLabel => 'Đánh giá';

  @override
  String get tradesPlanPending => 'Chưa kết nối dữ liệu';

  @override
  String get tradesReviewPending => 'Chưa kết nối dữ liệu';

  @override
  String get tradesDateValidationError => 'Vui lòng nhập ngày mở lệnh hợp lệ.';

  @override
  String get tradesNumberValidationError => 'Vui lòng nhập số hợp lệ.';

  @override
  String get tradesMissingReferenceTitle => 'Thiếu tài khoản hoặc instrument';

  @override
  String get tradesMissingReferenceBody => 'Hãy tạo tài khoản và instrument trước khi thêm giao dịch.';

  @override
  String get tradesCancel => 'Hủy';

  @override
  String get tradesSave => 'Lưu';

  @override
  String get tradesValidationMessage => 'Vui lòng nhập instrument và ngày hợp lệ.';

  @override
  String get tradesEditTooltip => 'Sửa giao dịch';

  @override
  String get tradesDeleteTooltip => 'Xóa giao dịch';

  @override
  String get tradesRiskStatusLabel => 'Trạng thái rủi ro';

  @override
  String get tradesRiskReasonLabel => 'Lý do vi phạm';

  @override
  String get tradesRiskStatusFollowed => 'Tuân thủ';

  @override
  String get tradesRiskStatusViolation => 'Vi phạm';

  @override
  String get tradesRiskReasonNotApplicable => 'Không áp dụng';

  @override
  String get tradesOverviewTitle => 'Nhật ký giao dịch';

  @override
  String get tradesOverviewSubtitle => 'Ghi nhận và rà soát các lệnh đã thực thi.';

  @override
  String get tradesOverviewBody => 'Danh sách lệnh và chi tiết lệnh sẽ được kết nối trong các lát cắt triển khai tiếp theo.';

  @override
  String get portfolioOverviewTitle => 'Tổng quan danh mục';

  @override
  String get portfolioOverviewSubtitle => 'Theo dõi nắm giữ, tỷ trọng và snapshot tài khoản.';

  @override
  String get portfolioOverviewBody => 'Màn hình timeline danh mục và holdings sẽ được bổ sung ở các lát cắt sắp tới.';

  @override
  String get portfolioCrudTitle => 'Danh mục';

  @override
  String get portfolioCrudSubtitle => 'Tạo, cập nhật và xóa snapshot tài khoản.';

  @override
  String get portfolioLoadErrorTitle => 'Không thể tải snapshot';

  @override
  String get portfolioLoadErrorBody => 'Vui lòng thử tải lại snapshot danh mục.';

  @override
  String get portfolioRetry => 'Thử lại';

  @override
  String get portfolioEmptyTitle => 'Chưa có snapshot';

  @override
  String get portfolioEmptyBody => 'Nhấn Thêm snapshot để tạo snapshot danh mục đầu tiên.';

  @override
  String get portfolioAddButton => 'Thêm snapshot';

  @override
  String get portfolioCreateTitle => 'Tạo snapshot';

  @override
  String get portfolioEditTitle => 'Sửa snapshot';

  @override
  String get portfolioSnapshotDateLabel => 'Ngày snapshot';

  @override
  String get portfolioSnapshotDateHint => 'YYYY-MM-DD';

  @override
  String get portfolioNoteLabel => 'Ghi chú';

  @override
  String get portfolioCancel => 'Hủy';

  @override
  String get portfolioSave => 'Lưu';

  @override
  String get portfolioValidationMessage => 'Vui lòng nhập ngày snapshot hợp lệ.';

  @override
  String get portfolioEquityLabel => 'Vốn chủ';

  @override
  String get portfolioEditTooltip => 'Sửa snapshot';

  @override
  String get portfolioDeleteTooltip => 'Xóa snapshot';

  @override
  String get portfolioHoldingsTitle => 'Nắm giữ';

  @override
  String get portfolioNoHoldings => 'Chưa có nắm giữ. Hãy thêm lệnh và quote để tạo bảng holdings.';

  @override
  String get portfolioHoldingInstrument => 'Mã';

  @override
  String get portfolioHoldingQuantity => 'SL';

  @override
  String get portfolioHoldingAvgCost => 'Giá vốn TB';

  @override
  String get portfolioHoldingMarketValue => 'Giá trị thị trường';

  @override
  String get portfolioHoldingUnrealizedPnl => 'Lãi/lỗ chưa thực hiện';

  @override
  String get portfolioHoldingWeight => 'Tỷ trọng';

  @override
  String get portfolioInputsTitle => 'Dữ liệu đầu vào';

  @override
  String get portfolioAddQuoteButton => 'Thêm / Cập nhật Quote';

  @override
  String get portfolioAddCashMovementButton => 'Thêm dòng tiền';

  @override
  String get portfolioQuoteFormTitle => 'Nhập quote';

  @override
  String get portfolioQuoteInstrumentLabel => 'Mã công cụ';

  @override
  String get portfolioQuotePriceLabel => 'Giá';

  @override
  String get portfolioCashFormTitle => 'Nhập dòng tiền';

  @override
  String get portfolioCashAmountLabel => 'Số tiền';

  @override
  String get portfolioSnapshotsTitle => 'Snapshots';

  @override
  String get portfolioSnapshotDetailTitle => 'Chi tiết snapshot';

  @override
  String get portfolioPositionsTitle => 'Vị thế';

  @override
  String get portfolioNoPositions => 'Không có vị thế trong snapshot này.';

  @override
  String get portfolioDailyPnlLabel => 'PnL ngày';

  @override
  String get portfolioCumulativePnlLabel => 'PnL lũy kế';

  @override
  String get portfolioDrawdownLabel => 'Sụt giảm';

  @override
  String get strategyRiskTitle => 'Chiến lược và rủi ro';

  @override
  String get strategyRiskSubtitle => 'Định nghĩa quy tắc chiến lược và kiểm soát rủi ro.';

  @override
  String get strategyRiskBody => 'Version chiến lược và kiểm tra rủi ro đã sẵn sàng ở tầng dữ liệu, UI sẽ được nối tiếp theo.';

  @override
  String get strategyLoadErrorTitle => 'Không thể tải dữ liệu chiến lược và rủi ro';

  @override
  String get strategyLoadErrorBody => 'Vui lòng thử tải lại chiến lược và rủi ro.';

  @override
  String get strategyRetry => 'Thử lại';

  @override
  String get strategyListTitle => 'Chiến lược';

  @override
  String get strategyAddButton => 'Thêm chiến lược';

  @override
  String get strategyEmptyState => 'Chưa có chiến lược hoạt động.';

  @override
  String get strategyAddVersionTooltip => 'Thêm phiên bản chiến lược';

  @override
  String get strategyArchiveTooltip => 'Lưu trữ chiến lược';

  @override
  String get strategyVersionHistoryTitle => 'Lịch sử phiên bản';

  @override
  String strategyVersionLabel(int version) {
    return 'Phiên bản $version';
  }

  @override
  String get strategyCreateTitle => 'Tạo chiến lược';

  @override
  String get strategyCreateVersionTitle => 'Tạo phiên bản chiến lược';

  @override
  String get strategyNameLabel => 'Tên chiến lược';

  @override
  String get strategyDescriptionLabel => 'Mô tả';

  @override
  String get strategyEntryRulesLabel => 'Quy tắc vào lệnh';

  @override
  String get strategyExitRulesLabel => 'Quy tắc thoát lệnh';

  @override
  String get strategyEffectiveFromLabel => 'Hiệu lực từ';

  @override
  String get strategyValidationMessage => 'Vui lòng nhập đủ trường bắt buộc và ngày hợp lệ.';

  @override
  String get riskRulesTitle => 'Quy tắc rủi ro';

  @override
  String get riskRuleAddButton => 'Thêm quy tắc';

  @override
  String get riskRulesEmptyState => 'Chưa có quy tắc rủi ro.';

  @override
  String riskApplicableRuleLabel(String name) {
    return 'Quy tắc đang áp dụng: $name';
  }

  @override
  String riskRuleSummary(String riskPercent, String maxDailyLoss) {
    return 'Rủi ro/lệnh: $riskPercent | Lỗ ngày tối đa: $maxDailyLoss';
  }

  @override
  String get riskRuleCreateTitle => 'Tạo quy tắc rủi ro';

  @override
  String get riskRuleNameLabel => 'Tên quy tắc';

  @override
  String get riskRulePercentLabel => 'Phần trăm rủi ro mỗi lệnh';

  @override
  String get riskRuleDailyLossLabel => 'Lỗ ngày tối đa';

  @override
  String get riskRuleValidationMessage => 'Vui lòng nhập tên quy tắc và ngày hiệu lực hợp lệ.';

  @override
  String get riskChecksTitle => 'Kiểm tra rủi ro';

  @override
  String get riskChecksEmptyState => 'Chưa có bản kiểm tra rủi ro.';

  @override
  String riskCheckTradeLabel(String tradeId) {
    return 'Giao dịch: $tradeId';
  }

  @override
  String get riskCheckNoViolationReason => 'Không có vi phạm.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dailyJournalTitle => 'Nhật ký hằng ngày';

  @override
  String get dailyJournalSubtitle => 'Lập kế hoạch trước phiên và đánh giá sau phiên.';

  @override
  String get dailyJournalLoadErrorTitle => 'Không thể tải nhật ký ngày';

  @override
  String get dailyJournalLoadErrorBody => 'Vui lòng thử tải lại các bản ghi nhật ký.';

  @override
  String get dailyJournalRetry => 'Thử lại';

  @override
  String get dailyJournalEmptyTitle => 'Chưa có nhật ký';

  @override
  String get dailyJournalEmptyBody => 'Nhấn Thêm nhật ký để tạo bản ghi đầu tiên.';

  @override
  String get dailyJournalAddButton => 'Thêm nhật ký';

  @override
  String get dailyJournalCreateTitle => 'Tạo nhật ký ngày';

  @override
  String get dailyJournalEditTitle => 'Sửa nhật ký ngày';

  @override
  String get dailyJournalDateLabel => 'Ngày nhật ký';

  @override
  String get dailyJournalPreMarketSectionTitle => 'Trước phiên';

  @override
  String get dailyJournalMarketViewLabel => 'Nhận định thị trường';

  @override
  String get dailyJournalTradingPlanLabel => 'Kế hoạch giao dịch';

  @override
  String get dailyJournalWatchlistLabel => 'Ghi chú watchlist';

  @override
  String get dailyJournalPostMarketSectionTitle => 'Sau phiên';

  @override
  String get dailyJournalCompletedActionsLabel => 'Việc đã thực hiện';

  @override
  String get dailyJournalFollowedPlanLabel => 'Có tuân thủ kế hoạch';

  @override
  String get dailyJournalWinsLabel => 'Điểm làm tốt';

  @override
  String get dailyJournalMistakesLabel => 'Sai lầm';

  @override
  String get dailyJournalFreeNoteLabel => 'Ghi chú tự do';

  @override
  String get dailyJournalDisciplineScoreLabel => 'Điểm kỷ luật';

  @override
  String get dailyJournalCancel => 'Hủy';

  @override
  String get dailyJournalSave => 'Lưu';

  @override
  String get dailyJournalValidationMessage => 'Vui lòng nhập ngày hợp lệ, đủ các phần bắt buộc và điểm từ 1-10.';

  @override
  String get dailyJournalEditTooltip => 'Sửa nhật ký';

  @override
  String dailyJournalScoreValue(int score) {
    return 'Điểm: $score/10';
  }

  @override
  String get psychologyTitle => 'Tâm lý giao dịch';

  @override
  String get psychologySubtitle => 'Ghi lại cảm xúc, tag hành vi và mức độ kỷ luật.';

  @override
  String get psychologyLoadErrorTitle => 'Không thể tải dữ liệu tâm lý';

  @override
  String get psychologyLoadErrorBody => 'Vui lòng thử tải lại dữ liệu tâm lý.';

  @override
  String get psychologyRetry => 'Thử lại';

  @override
  String get psychologyBody => 'Màn hình emotion log và phân tích hành vi sẽ được nối repository trong các lát cắt tiếp theo.';

  @override
  String get psychologyEmotionSectionTitle => 'Nhật ký cảm xúc';

  @override
  String get psychologyEmotionSectionSubtitle => 'Theo dõi cảm xúc theo phạm vi giao dịch hoặc nhật ký.';

  @override
  String get psychologyEmotionAddButton => 'Thêm cảm xúc';

  @override
  String get psychologyEmotionCreateTitle => 'Tạo nhật ký cảm xúc';

  @override
  String get psychologyEmotionEditTitle => 'Sửa nhật ký cảm xúc';

  @override
  String get psychologyEmotionTypeLabel => 'Cảm xúc';

  @override
  String get psychologyEmotionNoteLabel => 'Ghi chú';

  @override
  String get psychologyEmotionEmpty => 'Chưa có nhật ký cảm xúc.';

  @override
  String get psychologyTradeReferenceLabel => 'Giao dịch';

  @override
  String get psychologyJournalReferenceLabel => 'Nhật ký';

  @override
  String get psychologyEditTooltip => 'Sửa';

  @override
  String get psychologyDeleteTooltip => 'Xóa';

  @override
  String get psychologyBehaviorSectionTitle => 'Tag hành vi';

  @override
  String get psychologyBehaviorSectionSubtitle => 'Gắn hoặc bỏ tag hành vi cho một giao dịch.';

  @override
  String get psychologyBehaviorNoTrade => 'Chưa có giao dịch. Hãy tạo giao dịch trước khi gắn tag hành vi.';

  @override
  String get psychologyBehaviorTradeLabel => 'Giao dịch';

  @override
  String get psychologyBehaviorSearchHint => 'Tìm tag hành vi';

  @override
  String get psychologyBehaviorClearSearch => 'Xóa tìm kiếm';

  @override
  String psychologyEmotionIntensity(int value) {
    return 'Cường độ: $value';
  }

  @override
  String get psychologyDisciplineSectionTitle => 'Tự đánh giá kỷ luật';

  @override
  String get psychologyDisciplineSectionSubtitle => 'Ghi chú tự đánh giá và lọc theo phạm vi giao dịch hoặc nhật ký.';

  @override
  String get psychologyFilterLabel => 'Lọc theo phạm vi';

  @override
  String get psychologyFilterAll => 'Tất cả';

  @override
  String get psychologyFilterTrade => 'Giao dịch';

  @override
  String get psychologyFilterJournal => 'Nhật ký';

  @override
  String get psychologyEmptyDiscipline => 'Chưa có bản tự đánh giá.';

  @override
  String get psychologyAddReviewButton => 'Thêm đánh giá';

  @override
  String get psychologyCreateReviewTitle => 'Tạo tự đánh giá';

  @override
  String get psychologyScopeLabel => 'Phạm vi';

  @override
  String get psychologyDisciplineScoreLabel => 'Điểm kỷ luật';

  @override
  String get psychologySelfReviewLabel => 'Ghi chú tự đánh giá';

  @override
  String get psychologyCancel => 'Hủy';

  @override
  String get psychologySave => 'Lưu';

  @override
  String get psychologyValidationMessage => 'Vui lòng nhập ghi chú tự đánh giá.';

  @override
  String psychologyScoreLabel(int score) {
    return 'Điểm kỷ luật: $score/10';
  }

  @override
  String get insightsTitle => 'Phân tích và insight';

  @override
  String get insightsSubtitle => 'Biến lịch sử giao dịch thành cải thiện có thể đo lường.';

  @override
  String get insightsBody => 'Dashboard, so sánh và hộp thư insight rule-based là các mốc UI tiếp theo.';

  @override
  String modulePlaceholder(String module) {
    return 'Module $module sẽ sớm có mặt.';
  }
}
