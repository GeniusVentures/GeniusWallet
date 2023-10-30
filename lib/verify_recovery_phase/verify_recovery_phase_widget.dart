import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'verify_recovery_phase_model.dart';
export 'verify_recovery_phase_model.dart';

class VerifyRecoveryPhaseWidget extends StatefulWidget {
  const VerifyRecoveryPhaseWidget({Key? key}) : super(key: key);

  @override
  _VerifyRecoveryPhaseWidgetState createState() =>
      _VerifyRecoveryPhaseWidgetState();
}

class _VerifyRecoveryPhaseWidgetState extends State<VerifyRecoveryPhaseWidget> {
  late VerifyRecoveryPhaseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerifyRecoveryPhaseModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF18191D),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: Icon(
            Icons.chevron_left,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24.0,
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF0068EF),
              ),
              child: Align(
                alignment: AlignmentDirectional(-1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 30.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Verify Your Recovery Phrase',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 58.0),
                        child: Text(
                          'Tap the words to put them next to each other in the correct order',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Roboto',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 0.1,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
                child: Container(
                  width: 320.0,
                  height: 190.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF0068EF),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 49.0, 18.0, 0.0),
              child: FlutterFlowChoiceChips(
                options: [
                  ChipData('1 limb'),
                  ChipData('2 ask'),
                  ChipData('3 Orphan'),
                  ChipData('4 baby'),
                  ChipData('5 Merge'),
                  ChipData('6 toy'),
                  ChipData('7 winner'),
                  ChipData('8 Mobile'),
                  ChipData('9 visa'),
                  ChipData('10 obvious'),
                  ChipData('11 name'),
                  ChipData('12 style')
                ],
                onChanged: (val) =>
                    setState(() => _model.choiceChipsValue = val?.first),
                selectedChipStyle: ChipStyle(
                  backgroundColor: Color(0x00000000),
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                  iconColor: Color(0x00000000),
                  iconSize: 18.0,
                  elevation: 4.0,
                  borderColor: Color(0xFF00EFAE),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                unselectedChipStyle: ChipStyle(
                  backgroundColor: Color(0x00000000),
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Roboto',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 16.0,
                      ),
                  iconColor: FlutterFlowTheme.of(context).secondaryText,
                  iconSize: 18.0,
                  elevation: 0.0,
                  borderColor: FlutterFlowTheme.of(context).success,
                  borderRadius: BorderRadius.circular(0.0),
                ),
                chipSpacing: 13.33,
                rowSpacing: 12.0,
                multiselect: false,
                alignment: WrapAlignment.center,
                controller: _model.choiceChipsValueController ??=
                    FormFieldController<List<String>>(
                  [],
                ),
                wrapped: true,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(29.0, 203.0, 31.0, 0.0),
              child: FFButtonWidget(
                onPressed: () {
                  print('Button pressed ...');
                },
                text: 'Continue',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 40.0,
                  padding:
                      EdgeInsetsDirectional.fromSTEB(112.0, 0.0, 112.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Color(0xBCB1BBC8),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.normal,
                      ),
                  elevation: 3.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
