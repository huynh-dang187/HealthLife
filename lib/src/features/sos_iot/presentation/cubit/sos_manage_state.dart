enum SosManageAction { addRecipient, removeRecipient, leave, editDevice }

sealed class SosManageState {
  const SosManageState();
}

final class SosManageIdle extends SosManageState {
  const SosManageIdle();
}

final class SosManageBusy extends SosManageState {
  const SosManageBusy(this.action);

  final SosManageAction action;
}

final class SosManageError extends SosManageState {
  const SosManageError(this.messageKey);

  final String messageKey;
}