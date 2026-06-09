import '../models/savings_goal_style.dart';
import '../models/transaction.dart';
import '../providers/currency_provider.dart';
import '../providers/income_distribution_provider.dart';
import 'app_localizations.dart';

extension SavingsGoalStyleL10n on SavingsGoalStyle {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      SavingsGoalStyle.emergency => l10n.goalStyleEmergency,
      SavingsGoalStyle.trip => l10n.goalStyleTrip,
      SavingsGoalStyle.car => l10n.goalStyleCar,
      SavingsGoalStyle.home => l10n.goalStyleHome,
      SavingsGoalStyle.education => l10n.goalStyleEducation,
      SavingsGoalStyle.health => l10n.goalStyleHealth,
      SavingsGoalStyle.tech => l10n.goalStyleTech,
      SavingsGoalStyle.wedding => l10n.goalStyleWedding,
      SavingsGoalStyle.business => l10n.goalStyleBusiness,
      SavingsGoalStyle.gift => l10n.goalStyleGift,
    };
  }
}

extension TransactionCategoryL10n on TransactionCategory {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      TransactionCategory.food => l10n.txnCategoryFood,
      TransactionCategory.transport => l10n.txnCategoryTransport,
      TransactionCategory.entertainment => l10n.txnCategoryEntertainment,
      TransactionCategory.health => l10n.txnCategoryHealth,
      TransactionCategory.education => l10n.txnCategoryEducation,
      TransactionCategory.other => l10n.txnCategoryOther,
    };
  }
}

extension CurrencyL10n on Currency {
  String localizedName(AppLocalizations l10n) {
    return switch (code) {
      'COP' => l10n.currencyCop,
      'USD' => l10n.currencyUsd,
      'EUR' => l10n.currencyEur,
      'MXN' => l10n.currencyMxn,
      'BRL' => l10n.currencyBrl,
      _ => name,
    };
  }
}

extension DistributionBucketL10n on DistributionBucket {
  String localizedLabel(AppLocalizations l10n) {
    return switch (id) {
      'essentials' => l10n.bucketEssentials,
      'wants' => l10n.bucketWants,
      'savings' => l10n.bucketSavings,
      'debt' => l10n.bucketDebts,
      'investing' => l10n.bucketInvesting,
      'buffer' => l10n.bucketBuffer,
      _ => label,
    };
  }
}

extension IncomeDistributionTemplateL10n on IncomeDistributionTemplate {
  String localizedName(AppLocalizations l10n) {
    return switch (id) {
      'balanced_50_30_20' => l10n.templateBalancedName,
      'debt_first' => l10n.templateDebtFirstName,
      'investor' => l10n.templateInvestorName,
      'variable_income' => l10n.templateVariableName,
      IncomeDistributionProvider.customTemplateId => l10n.templateCustomName,
      _ => name,
    };
  }

  String localizedSubtitle(AppLocalizations l10n) {
    return switch (id) {
      'balanced_50_30_20' => l10n.templateBalancedSubtitle,
      'debt_first' => l10n.templateDebtFirstSubtitle,
      'investor' => l10n.templateInvestorSubtitle,
      'variable_income' => l10n.templateVariableSubtitle,
      IncomeDistributionProvider.customTemplateId => l10n.templateCustomSubtitle,
      _ => subtitle,
    };
  }
}
