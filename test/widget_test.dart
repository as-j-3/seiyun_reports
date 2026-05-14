import 'package:flutter_test/flutter_test.dart';
import 'package:seiyun_reports_app/screens/report/models/report_model.dart';

// محاكاة لخوارزمية Ray-Casting الموجودة في التطبيق
bool isPointInsidePolygon(double lat, double lng, List<List<double>> coordinates) {
  bool isInside = false;
  int i, j = coordinates.length - 1;
  for (i = 0; i < coordinates.length; i++) {
    double polyLngI = coordinates[i][0];
    double polyLatI = coordinates[i][1];
    double polyLngJ = coordinates[j][0];
    double polyLatJ = coordinates[j][1];
    
    if (((polyLatI > lat) != (polyLatJ > lat)) &&
        (lng < (polyLngJ - polyLngI) * (lat - polyLatI) / (polyLatJ - polyLatI) + polyLngI)) {
      isInside = !isInside;
    }
    j = i;
  }
  return isInside;
}

void main() {
  group('اختبارات الوظائف الأساسية للتطبيق', () {
    
    group('1. اختبارات نموذج البلاغات (ReportModel)', () {
      test('تحويل JSON كامل إلى كائن بشكل صحيح', () {
        final json = {
          'id': '123',
          'citizen_id': 456,
          'title': 'تسرب مياه',
          'area_id': 1,
          'description': 'يوجد تسرب مياه كبير في الشارع',
          'image': 'http://example.com/image.png',
          'status': 'مكتملة',
          'report_type': 'نظافة_شوارع',
          'lat': '15.9388',
          'lng': '48.8193',
          'created_at': '2026-05-14',
        };

        final report = ReportModel.fromJson(json);

        expect(report.id, 123);
        expect(report.citizenId, 456);
        expect(report.title, 'تسرب مياه');
        expect(report.status, 'مكتملة');
        expect(report.lat, '15.9388');
        expect(report.lng, '48.8193');
        expect(report.image, 'http://example.com/image.png');
      });

      test('التعامل مع البيانات الناقصة أو الفارغة بشكل آمن (القيم الافتراضية)', () {
        final json = <String, dynamic>{};

        final report = ReportModel.fromJson(json);

        expect(report.id, 0);
        expect(report.citizenId, 0);
        expect(report.title, 'بلاغ بدون عنوان');
        expect(report.status, 'قيد الانتظار');
        expect(report.reportType, 'رفع');
        expect(report.image, 'https://via.placeholder.com/150');
        expect(report.lat, '0.0');
        expect(report.lng, '0.0');
      });

      test('تحويل الكائن إلى JSON لإرساله للسيرفر لا يتضمن الحقول المحلية', () {
        final report = ReportModel(
          id: 1,
          citizenId: 2,
          title: 'Title',
          description: 'Desc',
          image: 'img',
          status: 'Pending',
          reportType: 'Type',
          lat: '1.0',
          lng: '2.0',
          createdAt: 'Now',
          areaId: 3,
        );

        final json = report.toJson();

        expect(json['title'], 'Title');
        expect(json['description'], 'Desc');
        expect(json['report_type'], 'Type');
        expect(json['lat'], '1.0');
        expect(json['lng'], '2.0');
        expect(json['image'], 'img');
        expect(json['area_id'], 3);
        
        expect(json.containsKey('id'), false);
        expect(json.containsKey('citizen_id'), false);
        expect(json.containsKey('created_at'), false);
      });
    });

    group('2. اختبارات خوارزمية التحقق من الموقع (Ray-Casting Algorithm)', () {
      final List<List<double>> squarePolygon = [
        [0.0, 0.0],
        [10.0, 0.0],
        [10.0, 10.0],
        [0.0, 10.0],
      ];

      test('إذا كان الموقع داخل المنطقة المسموحة، يجب أن يعود بـ true', () {
        expect(isPointInsidePolygon(5.0, 5.0, squarePolygon), isTrue);
        expect(isPointInsidePolygon(1.0, 1.0, squarePolygon), isTrue);
        expect(isPointInsidePolygon(9.9, 9.9, squarePolygon), isTrue);
      });

      test('إذا كان الموقع خارج المنطقة المسموحة، يجب أن يعود بـ false', () {
        expect(isPointInsidePolygon(15.0, 5.0, squarePolygon), isFalse);
        expect(isPointInsidePolygon(-1.0, 5.0, squarePolygon), isFalse);
        expect(isPointInsidePolygon(5.0, 15.0, squarePolygon), isFalse);
      });
    });

  });
}
