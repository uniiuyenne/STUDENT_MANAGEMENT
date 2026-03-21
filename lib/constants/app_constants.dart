class AppConstants {
  // Class list
  static const List<String> classes = [
    '65CNTT',
    '65HTTT',
    '65ANM',
    '65KTPM',
    '65DTVT',
    '65KĐT',
    '65DL',
    '65TKTC',
  ];

  // Department list
  static const List<String> departments = [
    'CNTT',
    'Kinh Tế',
    'Tài Nguyên Môi Trường',
    'Điện - Điện Tử',
    'Cơ Khí',
    'Xây Dựng',
    'Nông Lâm',
  ];

  // Subject list
  static const List<String> subjects = [
    'Lý Thuyết Tính Toán',
    'Giải Tích 1',
    'Giải Tích 2',
    'Giải Tích 3',
    'Đại Số Tuyến Tính',
    'Xác Suất Thống Kê',
    'Lập Trình C++',
    'Lập Trình Hướng Đối Tượng',
    'Cấu Trúc Dữ Liệu',
    'Thuật Toán',
    'Cơ Sở Dữ Liệu',
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Mạng Máy Tính',
    'Hệ Điều Hành',
  ];

  // GPA Status colors
  static const Map<String, int> statusColors = {
    'Xuất sắc': 0xFF4CAF50, // Green
    'Giỏi': 0xFF2196F3,     // Blue
    'Khá': 0xFFFFC107,      // Orange
    'Trung bình': 0xFFF44336, // Red
  };

  // GPA ranges
  static const Map<String, double> gpaRanges = {
    'Xuất sắc': 3.6,
    'Giỏi': 3.2,
    'Khá': 2.5,
    'Trung bình': 0.0,
  };
}
