import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blaise_wallet_flutter/appstate_container.dart';
import 'package:blaise_wallet_flutter/ui/util/app_icons.dart';
import 'package:blaise_wallet_flutter/ui/util/text_styles.dart';
import 'package:blaise_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:blaise_wallet_flutter/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';

/// An overlay that supports a list of options as well as text/confirm actions
class DialogOverlay extends StatefulWidget {
  final String title;
  final List<DialogListItem> optionsList;
  final bool warningStyle;
  final TextSpan body;
  final String confirmButtonText;
  final Function onConfirm;
  final bool payload;

  DialogOverlay(
      {this.title,
      this.optionsList,
      this.body,
      this.confirmButtonText,
      this.onConfirm,
      this.payload = true,
      this.warningStyle = false});

  @override
  State<StatefulWidget> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _scaleAnimation = Tween(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    _opacityAnimation = Tween(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.decelerate));
    _controller.addListener(() {
      setState(() {});
    });

    _controller.forward();
  }

  buildListItems(List<DialogListItem> optionsList) {
    List<Widget> widgets = [];
    for (var option in optionsList) {
      widgets.add(
        // Single Option
        Container(
          width: double.maxFinite,
          height: 50,
          child: FlatButton(
              onPressed: option.action == null
                  ? () {
                      return null;
                    }
                  : option.action,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              padding: EdgeInsets.all(0),
              child: Container(
                alignment: Alignment(-1, 0),
                margin: EdgeInsetsDirectional.only(start: 24, end: 24),
                child: AutoSizeText(
                  option.option,
                  style: option.disabled
                      ? AppStyles.paragraphBigDisabled(context)
                      : AppStyles.paragraphBig(context),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  stepGranularity: 0.1,
                ),
              )),
        ),
      );
    }
    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: EdgeInsetsDirectional.only(start: 20, end: 20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: widget.payload
                      ? MediaQuery.of(context).size.width - 40
                      : 280,
                ),
                decoration: BoxDecoration(
                  color: StateContainer.of(context).curTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: StateContainer.of(context).curTheme.shadow50,
                      offset: Offset(0, 30),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      widget.payload
                          ? SizedBox()
                          :
                          // Header of the modal
                          Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                gradient: widget.warningStyle
                                    ? null
                                    : StateContainer.of(context)
                                        .curTheme
                                        .gradientPrimary,
                                color: widget.warningStyle
                                    ? StateContainer.of(context).curTheme.danger
                                    : null,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)),
                              ),
                              child: Container(
                                margin: EdgeInsetsDirectional.fromSTEB(
                                    24, 16, 24, 16),
                                child: AutoSizeText(
                                  widget.title,
                                  style: AppStyles.modalHeader(context),
                                  maxLines: 1,
                                  stepGranularity: 0.1,
                                ),
                              ),
                            ),
                      // Options container
                      widget.body != null
                          ? Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsetsDirectional.fromSTEB(
                                      24, 16, 24, 16),
                                  child: Column(
                                    children: <Widget>[
                                      AutoSizeText.rich(
                                        widget.body,
                                        stepGranularity: 0.1,
                                        maxLines: 8,
                                        minFontSize: 8,
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    AppButton(
                                      type: AppButtonType.Danger,
                                      text: widget.confirmButtonText,
                                      buttonTop: true,
                                      onPressed: () {
                                        if (widget.onConfirm != null) {
                                          widget.onConfirm();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    AppButton(
                                      type: AppButtonType.DangerOutline,
                                      text: "CANCEL",
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.6 -
                                          60,
                                  minHeight: 0),
                              // Options list
                              child: widget.payload
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        // Container for the amount text field
                                        Container(
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20, 24, 20, 0),
                                          child: AppTextField(
                                            label: 'Payload',
                                            style: AppStyles.paragraph(
                                                context),
                                            maxLines: 1,
                                            firstButton: TextFieldButton(
                                                icon: AppIcons.paste),
                                            secondButton: TextFieldButton(
                                                icon: AppIcons.scan),
                                          ),
                                        ),
                                        // Container for the "Add Payload" button
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                color:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .backgroundPrimary,
                                                boxShadow: [
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .shadowTextDark,
                                                ],
                                              ),
                                              margin: EdgeInsetsDirectional
                                                  .fromSTEB(20, 30, 20, 24),
                                              child: FlatButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0)),
                                                child: AutoSizeText(
                                                  "Encrypt the Payload",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  stepGranularity: 0.1,
                                                  style: AppStyles.buttonMiniBg(
                                                      context),
                                                ),
                                                onPressed: () async {
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : SingleChildScrollView(
                                      padding: EdgeInsetsDirectional.only(
                                          top: 8, bottom: 8),
                                      child: buildListItems(widget.optionsList),
                                    ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DialogListItem {
  final String option;
  final Function action;
  final bool disabled;
  DialogListItem({@required this.option, this.action, this.disabled = false});
}

/// Modified dialog function from flutter source. Modified for the backdrop blur effect

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

Future<T> showAppDialog<T>({
  @required
      BuildContext context,
  bool barrierDismissible = true,
  @Deprecated(
      'Instead of using the "child" argument, return the child from a closure '
      'provided to the "builder" argument. This will ensure that the BuildContext '
      'is appropriate for widgets built in the dialog.')
      Widget child,
  WidgetBuilder builder,
}) {
  assert(child == null || builder == null);
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = child ?? Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: StateContainer.of(context).curTheme.overlay10,
    transitionDuration: const Duration(milliseconds: 0),
    transitionBuilder: _buildMaterialDialogTransitions,
  );
}
