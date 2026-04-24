enum ButtonSize {
  xxLarge,
  xLarge,
  large,
  medium,
  small,
  xSmall,
  xxSmall,
}

double getButtonSize(ButtonSize buttonSize) {
  switch (buttonSize) {
    case ButtonSize.xxLarge:
      return 48;
    case ButtonSize.xLarge:
      return 44;
    case ButtonSize.large:
      return 40;
    case ButtonSize.medium:
      return 36;
    case ButtonSize.small:
      return 32;
    case ButtonSize.xSmall:
      return 28;
    case ButtonSize.xxSmall:
      return 24;
    default:
      return 44;
  }
}
