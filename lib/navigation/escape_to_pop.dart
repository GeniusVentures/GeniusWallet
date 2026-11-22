import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pops the topmost route on Escape, one route per press. Mounted around the
/// navigator: it sits closer to the focus than WidgetsApp's own Escape
/// mapping (DismissIntent, a no-op on pages, whose barrierDismissible is
/// false), and anything with a closer Escape handler - the account drawer's
/// shortcuts, a text field's IME - claims the key before this sees it.
class EscapeToPop extends StatelessWidget {
  const EscapeToPop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{EscapeIntent: EscapePopAction()},
        child: child,
      ),
    );
  }
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

/// maybePop, not pop: a PopScope that refuses (checkout mid-payment) stays,
/// a dialog pops first, and the lone root route bubbles instead of vanishing.
class EscapePopAction extends Action<EscapeIntent> {
  @override
  Object? invoke(EscapeIntent intent) {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    final navigator = focusContext == null
        ? null
        : Navigator.maybeOf(focusContext);
    navigator?.maybePop();
    return null;
  }
}
