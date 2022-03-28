import 'package:flutter_test/flutter_test.dart';
import 'package:r_sdk_m/src/Helper/helper.dart';
import 'package:r_sdk_m/src/Utils/gb_utils.dart';
import 'package:r_sdk_m/src/Utils/utils.dart';

import '../Helper/gb_test_helper.dart';

void main() {
  group('GBUtils', () {
    test('Test Hash', () {
      final evaluateCondition = GBTestHelper.getFNVHashData();
      List<String> failedScenarios = <String>[];
      List<String> passedScenarios = <String>[];
      for (final item in evaluateCondition) {
        final testContext = item[0];
        final experiment = item[1];

        final result = GBUtils().hash(testContext);

        final status = item[0].toString() +
            '\nExpected Result - ' +
            item[1].toString() +
            '\nActual result - ' +
            result.toString() +
            '\n' +
            'of experiment' +
            experiment.toString();

        if (experiment.toString() == result.toString()) {
          passedScenarios.add(status);
        } else {
          failedScenarios.add(status);
        }
      }
      expect(failedScenarios.length, 0);
    });

    ///TDOD :
    test('Test Bucket Range', () {
      List<GBBucketRange> getPairedData(List<List<double>> items) {
        final List<Tuple2<double, double>> pairedExpectedResults = [];
        for (final item in items) {
          final pair = item.zipWithNext();
          pairedExpectedResults.add(Tuple2.fromList(pair));
        }
        return pairedExpectedResults;
      }

      bool compareBucket(List<List<double>> expectedResult,
          List<GBBucketRange> calculatedResult) {
        var pairedExpectedResult = getPairedData(expectedResult);
        if (pairedExpectedResult.length != expectedResult.length) {
          return false;
        }
        var result = true;
        for (var i = 0; i < pairedExpectedResult.length; i++) {
          var source = pairedExpectedResult[i];
          var target = calculatedResult[i];

          if (source.item1 != target.item1 || source.item2 != target.item2) {
            result = false;
            break;
          }
        }
        return result;
      }

      final evalConditions = GBTestHelper.getBucketRangeData();
      List<String> failedScenarios = <String>[];
      List<String> passedScenarios = <String>[];

      for (final item in evalConditions) {
        if ((item as Object?).isArray) {
          ///
          final localItem = item as List;
          ////
          final numVariation = localItem[1][0];
          ////
          final coverage = localItem[1][1];

          ///
          List<double> weights = [];
          if (localItem[1][2] != null) {
            weights = ((localItem[0][2]) ?? [])
                .map((e) => double.parse(e.toString()))
                .toList();
          }

          final bucketRange = GBUtils().getBucketRanges(
              numVariation, double.parse(coverage.toString()), weights);

          /// For status.
          final status = item[0].toString() +
              "\nExpected Result - " +
              item[2].toString() +
              "\nActual result - " +
              bucketRange.toString() +
              "\n";
          print(localItem[2]);
          if (compareBucket(localItem.cast<List<double>>(), bucketRange!)) {
            passedScenarios.add(status);
          } else {
            failedScenarios.add(status);
          }
        }
      }
    });
  });
}