import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

import '../utils/color_util.dart';
import '../widgets/app_bar_widget.dart';

class QuotationScreen extends StatelessWidget {
  final String quotationURL;
  const QuotationScreen({super.key, required this.quotationURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(mayPop: true),
      body: FutureBuilder(
        future: PDFDocument.fromURL(quotationURL),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.hasError) {
            print('HAS DATA: ${snapshot.hasData}');
            return Text('Error viewing PDF');
          }
          return PDFViewer(
            document: snapshot.data!,
            pickerButtonColor: CustomColors.grenadine,
          );
        },
      ),
    );
  }
}
