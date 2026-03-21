# 📚 Student Manager - Ứng Dụng Quản Lý Sinh Viên

## 🎯 Giới Thiệu Dự Án

**Student Manager** là một ứng dụng Flutter toàn diện cho phép quản lý thông tin sinh viên một cách hiệu quả. Ứng dụng cung cấp các tính năng quản lý dữ liệu sinh viên, lọc, tìm kiếm, xem thống kê chi tiết, tính toán học phí, và hỗ trợ chế độ tối/sáng.

**Mục tiêu:** Ứng dụng tổng hợp kiến thức về UI/UX, Local/Network Data, State Management, Điều hướng màn hình, và Animations để giải quyết bài toán quản lý trạng thái liên màn hình.

---

## 📋 YÊU CẦU CHUNG

- **Hình thức:** Dự án cá nhân/nhóm
- **Dạng dữ liệu:** Sử dụng Supabase/Firestore hoặc dữ liệu local (JSON mock)
- **Kiến trúc:** MVC/MVVM với các thư mục: `models/`, `screens/`, `widgets/`, `providers/`, `services/`, `constants/`, `utils/`
- **State Management:** Bắt buộc sử dụng **Provider** (hoặc GetX) để quản lý trạng thái toàn ứng dụng
- **Giao diện:** Bám sát chuẩn Material Design 3, hỗ trợ cả Light/Dark Theme
- **Animations:** Có các hiệu ứng chuyển cảnh mượt mà (Slide, Fade, Scale Transitions)
- **Data Persistence:** Lưu dữ liệu offline bằng SharedPreferences hoặc Firebase Realtime Database

---

## 🎨 YÊU CẦU CHỨC NĂNG & GIAO DIỆN (ĐẠT CHUẨN CỒNG NGHỆ QUẢN LÝ)

Dự án yêu cầu hoàn thiện luồng quản lý sinh viên khép kín với 4 màn hình cốt lõi. Giao diện ưu tiên bám sát trải nghiệm người dùng (UX) của các ứng dụng quản lý chuyên nghiệp.

---

### **MÀN HÌNH 1: DANH SÁCH SINH VIÊN (STUDENT LIST SCREEN) - Tối ưu hóa UI/UX**

#### **SliverAppBar & Hiệu ứng Cuộn (Scroll Effects):**
- **Thanh Tìm Kiếm (Search Bar):**
  - Nằm ở trên cùng AppBar, có prefixIcon tìm kiếm + suffixIcon xóa text
  - TextField với placeholder "Tìm tên, mã SV, email..."
  - Khi người dùng cuộn danh sách xuống, thanh tìm kiếm phải **dính (sticky)** ở đỉnh màn hình
  - Đổi màu nền: Từ gradient (transparent) sang solid primary color khi scroll
  
- **Góc Phải AppBar:**
  - Icon **Theme Toggle** (Sun/Moon icon, màu cam) - Click để switch Dark/Light Mode
  - Icon **Statistics** (biểu đồ cột) - Click để điều hướng sang Thống kê
  - Lưu theme preference vào SharedPreferences
  
- **Gradient Background:**
  - Nền AppBar: Gradient từ Tím (#7C3AED) → Xanh Nhạt (#2196F3)

#### **Filter Header Widget (Custom Widget - Sticky):**
- **Vị trí:** Nằm dưới Search Bar, cố định khi scroll
- **Nội dung hiển thị:**
  - Tiêu đề: "🎯 Danh Sách Sinh Viên"
  - Số lượng: "50/150 sinh viên" (filtered/total)
  - Nút "Chọn lọc" với Icon filter + Badge hiển thị số bộ lọc đang hoạt động
  - Click nút → Mở **FilterBottomSheet**

#### **Logic BottomSheet Lọc (Filter Bottom Sheet):**
- **Trigger:** Khi bấm nút "Chọn lọc"
- **Giao diện:**
  - Không chuyển trang, màn hình hiện tại tối, BottomSheet đẩy lên từ dưới đáy
  - Header: "Filter students" + Icon close (X)
  - 3 TextFormFields với Autocomplete:
    - Dropdown Lớp (Classes)
    - Dropdown Khoa (Departments)
    - TextFormField Min GPA (Number input)
  - 2 Nút dưới đáy: "Clear" (Outlined) + "Apply" (Filled xanh)
  
- **Logic:**
  - Khi "Apply" → Đóng BottomSheet → Cập nhật danh sách realtime
  - Khi "Clear" → Reset tất cả filter → Dữ liệu back về toàn bộ sinh viên
  - Số sinh viên ở Filter Header tự động cập nhật

#### **Danh Sách Sinh Viên (Student Card ListView):**
- **Card Layout:**
  - Row chứa: Avatar (tròn 50x50) + Thông tin
  - **Avatar:** Ảnh tròn với border shadow, placeholder nếu không có ảnh
  - **Thông Tin:**
    - **Tên SV:** In đậm, font 16, tối đa 1 dòng (ellipsis nếu dài)
    - **Lớp + Khoa:** Font 12, màu xám (#999)
    - **GPA Badge:** Sang phải, màu xanh (≥3.2), cam (2.5-3.2), đỏ (<2.5)
    - **Mã SV:** Dưới cùng, font 11, màu xám nhạt

- **Tính Năng Tìm Kiếm Động:**
  - Tìm kiếm theo: Tên, Mã SV, Email
  - Khi gõ → Filter realtime (không cần bấm nút)
  - Highlight keyword tìm kiếm trên card

- **Pull to Refresh:**
  - Vuốt từ trên xuống để gọi `fetchStudents()` lại từ API
  - Hiện loading indicator (Circular Progress)
  - Sau khi xong, hiện Snackbar "Cập nhật thành công"

- **Infinite Scroll (Pagination):**
  - Khi cuộn xuống đáy danh sách, tự động gọi API tải thêm trang tiếp theo
  - Hiện loading spinner ở cuối danh sách
  - Append sinh viên mới vào danh sách (không reset)

- **Empty State UI:**
  - Nếu danh sách trống → Hiện "Không có sinh viên" + Neutral icon
  - Nếu tìm kiếm không có kết quả → "Không tìm thấy sinh viên phù hợp"

#### **Thao Tác Vuốt (Swipe Actions - Dismissible):**
- **Vuốt sang trái:**
  - Hiện background đỏ (#FF5252) + Icon thùng rác (delete)
  - Press → Mở Dialog xác nhận xóa
  - Dialog "Bạn có chắc muốn xóa [Tên]?" → Nút "Hủy" + "Xóa"
  - Xóa thành công → Snackbar "Xóa thành công" + Cập nhật danh sách

#### **Animations & Transitions:**
- **PageRoute Transition:** Khi chuyển sang Chi tiết → **Slide Transition** (slide từ phải vào)
- **Button Ripple:** Tất cả button đều có material ripple effect
- **Loading Spinner:** Hiên khi fetchStudents() hoặc infinite scroll

---

### **MÀN HÌNH 2: CHI TIẾT SINH VIÊN (STUDENT DETAIL SCREEN) - Hiệu ứng Hero & BottomSheet Logic**

#### **Hero Animation (Khi Mở Chi Tiết):**
- Khi bấm vào avatar hoặc card sinh viên → Avatar phóng to mượt mà sang trang Chi tiết
- Sử dụng `Hero` widget bao quanh ảnh avatar
- AppBar mới slide vào từ trên (Slide Transition)

#### **Giao Diện Trình Bày:**

- **Header Section:**
  - Avatar lớn (kích thước 120x120), tròn với `BoxShadow`
  - Tên sinh viên: Font 24, fontWeight bold, center align
  - Mã sinh viên: Font 12, màu xám, dưới tên
  - Background: Gradient (tím → xanh)

- **Khối Thông Tin Cơ Bản (Card):**
  - ListTile format với Icon + Text:
    - 📧 Email: `student@email.com`
    - 📱 Điện thoại: `0901234567`
    - 🎂 Ngày sinh: `15/06/2003`
    - 👤 Giới tính: `Nam`
    - 🏠 Địa chỉ: `123 Đường ABC, TP HCM`
  - Header Card: GPA (xanh lớn, font 20 bold) + Xếp loại (Badge màu)
  
- **Khối Học Tập:**
  - Row chứa: Lớp (Chip), Khoa (Chip), Năm học
  - `Chip` có background light + border

- **Khối Học Phí (Tuition Card):**
  - Tiêu đề: "💰 Học Phí Năm Học Hiện Tại"
  - Hiển thị tổng: `15.600.000đ` (Định dạng tiền VND)
  - **Nút "Chi tiết":** 
    - Nền xanh (#2196F3), chữ trắng
    - Click → Mở **TuitionDetailDialog** (Modal Dialog)
  
  - **Logic TuitionDetailDialog (Modal - Không BottomSheet):**
    - Hiển thị bảng chi tiết:
      - Cột: Môn học | Credits | Đơn giá/Credit | Tổng tiền
      - Lấy dữ liệu từ Student model (danh sách môn học)
      - Tính: credits × 300.000 VND
    - Bottom Dialog: Tổng học phí (Bold, màu xanh)
    - Nút "Đóng" (Close button)
    - Không blocking, người dùng có thể dismiss bằng bấm ngoài dialog

- **Bottom Action Bar (Fixed - Stickypad dưới đáy):**
  - Row chứa 2 nút:
    - Nút "✏️ Sửa": Nền xanh nhạt, Click → Navigator.push đến AddEditStudentScreen
    - Nút "🗑️ Xóa": Nền đỏ (#FF5252), Click → Mở Dialog xác nhận
  - Nút cố định dưới đáy, không bị cuộn
  - Có padding + safe area inset

- **Delete Confirmation Dialog:**
  - Title: "Xác nhận xóa"
  - Content: "Bạn có chắc muốn xóa [Tên sinh viên]?"
  - 2 Actions: "Hủy" (Outlined) + "Xóa" (Filled đỏ)
  - Xóa thành công:
    - Snackbar "Xóa thành công"
    - Pop về StudentListScreen
    - StudentProvider cập nhật danh sách

#### **Animations:**
- **AppBar slide-in:** Từ trên vào
- **Content fade-in:** Fade transition cho content
- **Button hover:** Scale + opacity change khi hover
- **Hero animation:** Avatar phóng to từ list → detail

---

### **MÀN HÌNH 3: THỐNG KÊ (STATISTICS SCREEN) - Dynamic Tabs & State Management**

Giao diện ưu tiên bám sát **Trải nghiệm người dùng (UX)** của các ứng dụng thống kê chuyên nghiệp.

#### **Cấu Trúc Layout (Từ Trên Xuống):**

**1. Filter Buttons Row - Level Trên (ALWAYS VISIBLE):**
- **Vị trí:** Ngay dưới AppBar, có padding
- **3 Nút Toggle Chính:**
  - `"Toàn bộ"` (default active)
  - `"Theo Lớp"`
  - `"Theo Khoa"`
- **Logic:**
  - Chỉ 1 nút được active tại 1 thời điểm
  - Active button: Nền xanh (#2196F3), chữ trắng
  - Inactive button: Nền xám nhạt, chữ đen
  - Click → `setState` để đổi `_filterType` + Reset selector + Cập nhật dữ liệu tabs
  - Scroll ngang nếu màn hình nhỏ (Horizontal)

**2. Selector Field - Level Giữa (CONDITIONAL - Không Lúc Nào Cũng Hiện):**
- **Hiển thị CHỈ KHI:**
  - `_filterType == 'class'` → Show Autocomplete Lớp học
  - `_filterType == 'department'` → Show Autocomplete Khoa
  - `_filterType == 'all'` → KHÔNG hiển thị selector

- **Selector UI:**
  - TextFormField với `Autocomplete<String>`
  - Placeholder: "Chọn hoặc nhập lớp" / "Chọn hoặc nhập khoa"
  - Dropdown suggestions từ `AppConstants.classes` / `AppConstants.departments`
  - Icon prefix: 🏫 (lớp) hoặc 🏛️ (khoa)
  - Padding: Horizontal 16, Vertical 8
  - Real-time update quando thay đổi

**3. TabBar - Level Dưới (ALWAYS VISIBLE cho tất cả filter types):**
- **3 Tabs Cố Định:**
  - `"📊 Phân loại"` - Classification Kiểu
  - `"📈 Biểu đồ"` - Chart visualization
  - `"📋 Chi tiết"` - Detailed statistics table

- **Features:**
  - Nằm trong `Material` widget với background color
  - Hỗ trợ vuốt ngang (swipe) để chuyển tab
  - Hoặc click trực tiếp vào tab text
  - TabController managed bằng `_tabController` (length: 3)

**4. TabBarView (Expanded - Takes Remaining Space):**
- Từ TabBar xuống chiếm hết chỗ trống
- 3 Tab Views tương ứng: Classification → Chart → Details

---

#### **Chi Tiết 3 Tabs (Data Luôn Căn Cứ Theo Filter Type + Selector):**

**Tab 1: Phân Loại (Classification List):**
- **Tổng Quan Card (Top):**
  - Gradient background (tím → xanh)
  - Icon 👥, Text "Tổng cộng", số lượng sinh viên (font 24 bold)
  
- **Danh sách Phân loại (ListTile Cards):**
  - **Xuất sắc** (⭐⭐⭐⭐) - GPA ≥ 3.6:
    - Card với gradient xanh lá
    - Hiển thị: Số lượng + Phần trăm
    - Progress bar từ 0 → percentage
  
  - **Giỏi** (⭐⭐⭐) - GPA 3.2-3.6:
    - Card với gradient xanh dương
  
  - **Khá** (⭐⭐) - GPA 2.5-3.2:
    - Card với gradient cam
  
  - **Trung bình** (⭐) - GPA < 2.5:
    - Card với gradient đỏ
  
  - Mỗi card layout:
    - Icon + Tên xếp loại (trái)
    - Số lượng + Phần trăm (phải)
    - Progress bar (full width)

**Tab 2: Biểu Đồ (PieChart Visualization):**
- **PieChart từ package `fl_chart`:**
  - 4 sections: Xuất sắc (xanh lá), Giỏi (xanh), Khá (cam), Trung bình (đỏ)
  - Mỗi section hiển thị: Tên + Số lượng
  - Animations khi data thay đổi (Tween animation)
  - Height: 250px

- **Legend (Dưới Biểu Đồ):**
  - Horizontal ListView chứa các mục:
    - ⚫ Xuất sắc: 10
    - ⚫ Giỏi: 25
    - ⚫ Khá: 40
    - ⚫ Trung bình: 25

**Tab 3: Chi Tiết (Statistics Table):**
- **Table Layout:**
  - Columns: Xếp loại | Số lượng | Phần trăm
  - Header row (nền xanh): Bold text, white color
  - 4 Data rows (cạnh nhau):
    - Xuất sắc | 10 | 14.3%
    - Giỏi | 25 | 35.7%
    - Khá | 30 | 42.9%
    - Trung bình | 5 | 7.1%
  
  - **Table Border:**
    - Horizontal + Vertical interior borders
    - All cell padding = 12px
    - Fixed column width (VD: 100, 80, 80)
  
  - **Responsive:**
    - SingleChildScrollView ngang nếu table quá rộng
    - Container wrapper với border + borderRadius

---

#### **State Management & Data Flow:**

- **Instance Variables:**
  ```dart
  String _filterType = 'all';  // 'all' | 'class' | 'department'
  String? _selectedClass;       // Nullable
  String? _selectedDepartment;  // Nullable
  late TabController _tabController;
  ```

- **Data Calculation:**
  - `_getFilteredStudents()`: Return List<Student> dựa trên `_filterType` + selector
  - `_calculateStats()`: Return Map với {total, excellent, verygood, good, average}
  - Gọi lại 2 hàm này mỗi khi filter/selector thay đổi

- **Real-time Updates:**
  - Khi click filter button → `setState` → Re-calculate stats → All tabs update
  - Khi thay đổi selector → `setState` → Data realtime
  - Không cần page reload, mọi thứ seamless

#### **Animations:**
- **Tab Transition:** Material 3 style (Fade + scale)
- **Card Entry:** Fade-in khi data load
- **Pie Chart:** Tween animation khi data thay đổi
- **Progress Bar:** Animated transition

---

### **MÀN HÌNH 4: THÊM/SỬA SINH VIÊN (ADD/EDIT STUDENT SCREEN) - Form Validation & State**

#### **AppBar & Navigation:**
- **Title:**
  - "Thêm sinh viên mới" (Mode add - route từ Danh sách)
  - "Sửa thông tin sinh viên" (Mode edit - route từ Chi tiết + truyền Student object)
- **Leading Button:** Close icon (X) → Pop màn hình
- **AppBar Action:** Tùy chọn (Leave empty hoặc help icon)
- **Transition:** Fade transition khi open

#### **Form Input Sections:**

**Section 1: Thông Tin Cá Nhân**
- **TextFormField - Tên SV:**
  - Placeholder: "Nhập tên sinh viên"
  - Validation: Bắt buộc, max 100 ký tự, min 2 ký tự
  - Error message: "Tên là bắt buộc" / "Tên tối đa 100 ký tự"
  - Icon: 👤

- **TextFormField - Email:**
  - Placeholder: "student@email.com"
  - InputType: EmailAddress
  - Validation: Email format regexp, required
  - Error: "Email không hợp lệ"
  - Icon: 📧

- **TextFormField - Số Điện Thoại:**
  - Placeholder: "0901234567"
  - InputType: Phone
  - Validation: Định dạng SĐT Việt Nam, bắt buộc
  - Error: "SĐT không hợp lệ"
  - Icon: 📱

- **TextFormField - Địa Chỉ:**
  - Placeholder: "123 Đường ABC, TP HCM"
  - Max lines: 3 (multiline)
  - Validation: Required
  - Icon: 🏠

**Section 2: Thông Tin Học Tập**
- **Dropdown - Lớp:**
  - Danh sách từ `AppConstants.classes`
  - Initial value: Nếu edit mode thì pre-select
  - Validation: Required
  - Decoration: Prefix icon 🏫

- **Dropdown - Khoa:**
  - Danh sách từ `AppConstants.departments`
  - Initial value: Pre-select nếu edit
  - Validation: Required
  - Prefix icon: 🏛️

- **Dropdown - Giới Tính:**
  - Options: "Nam", "Nữ", "Khác"
  - Pre-select nếu edit
  - Prefix icon: 👥

- **DatePicker - Ngày Sinh:**
  - Trigger: GestureDetector trên TextField
  - Show DatePicker dialog khi tap
  - Display: "DD/MM/YYYY" format
  - Validation: Phải là ngày trong quá khứ
  - Prefix icon: 🎂

**Section 3: Thông Tin Học Tập (Numeric)**
- **TextFormField - GPA:**
  - InputType: NumberWithOptions (allow decimal)
  - Placeholder: "3.5"
  - Validation: 0.0 - 4.0, required
  - Error: "GPA phải từ 0.0 đến 4.0"
  - Icon: ⭐

**Section 4: Avatar Picker (Bonus)**
- **GestureDetector Avatar + Camera Icon:**
  - Click → Bottom sheet với 2 option: "Chụp ảnh" + "Chọn từ thư viện"
  - Thumbnail hiển thị ảnh đã chọn hoặc placeholder
  - Sử dụng `image_picker` package

#### **Form Validation Architecture:**
- **Real-time Validation:**
  - Mỗi field `onChanged` → Call `_formKey.currentState?.validate()`
  - Hiện error messages dưới field khi sai
  - Text decoration error color đỏ
  
- **Submit Button Enable Logic:**
  - Nút "Lưu" chỉ enable khi `_formKey.currentState?.validate() == true`
  - Nếu form invalid → Button highlighted với opacity lower
  - Nếu valid → Button full color + on pressed active

#### **Bottom Action Bar (Sticky - Fixed dưới):**
```
    [Hủy (Outlined)]  [      Lưu (Filled Xanh)     ]
```
- **Nút "Hủy":**
  - OutlinedButton, chữ đen, border
  - Click → Dialog xác nhận "Bạn muốn hủy thay đổi?" → Pop nếu OK

- **Nút "Lưu":**
  - ElevatedButton, nền xanh, chữ trắng
  - Khi press:
    1. Trigger validation
    2. Nếu valid → Show loading spinner (CircularProgressIndicator)
    3. Gọi `StudentProvider.addStudent()` hoặc `updateStudent()`
    4. Chờ API response
    5. Nếu success:
       - Snackbar "Lưu thành công"
       - Cập nhật StudentProvider (notify listeners)
       - Pop về screen trước (StudentListScreen hoặc StudentDetailScreen)
    6. Nếu error:
       - Snackbar error message từ API
       - Giữ form mở để user retry

#### **Mode Edit (Pre-fill):**
- Khi route đến AddEditStudentScreen với `Student` object:
  - Tất cả fields automatically pre-fill dữ liệu cũ
  - Title thay đổi → "Sửa thông tin sinh viên"
  - Nút Lưu gọi `updateStudent()` thay vì `addStudent()`

#### **Animations:**
- **Page Transition:** Fade Transition khi open/close
- **Button Press:** Ripple + opacity change
- **Loading:** Circular progress indic khi submit
- **Snackbar:** Slide up animation

---

---

### **MÀN HÌNH 5: CẤU HÌNH CHUNG (THEME & SETTINGS)**

- **Theme Toggle:**
  - Icon Sun/Moon ở AppBar Danh sách (góc phải)
  - Click → Toggle Dark/Light mode toàn ứng dụng
  - Lưu preference vào SharedPreferences → Persist qua app restarts

- **Color Scheme:**
  - **Light Mode:**
    - Primary: Xanh dương (#2196F3)
    - Secondary: Tím (#7C3AED)
    - Background: Trắng (#FFFFFF)
    - Surface: Xám nhạt (#F5F5F5)
  
  - **Dark Mode:**
    - Primary: Xanh dương nhạt (#1E88E5)
    - Secondary: Tím nhạt (#5C6BC0)
    - Background: Đen (#121212)
    - Surface: Xám đậm (#1E1E1E)

---

## ⚙️ YÊU CẦU KỸ THUẬT & TỔ CHỨC SOURCE CODE (Chi Tiết Kỹ Thuật)

### **1. Kiến Trúc Thư Mục & Mô-đun Hóa:**
```
lib/
├── main.dart                          # Entry point + MultiProvider setup
│
├── config/
│   ├── firebase_options.dart          # Firebase config
│   └── supabase_config.dart           # Supabase config
│
├── constants/
│   └── app_constants.dart             # Classes, Departments, GPA ranges, colors
│
├── models/
│   └── student.dart                   # Student data class + JSON serialization
│
├── providers/
│   ├── student_provider.dart          # ChangeNotifierProvider - Main state
│   └── theme_provider.dart            # ThemeProvider - Dark/Light toggle
│
├── screens/
│   ├── student_list/
│   │   └── student_list_screen.dart   # Màn hình danh sách (Main)
│   ├── student_detail/
│   │   └── student_detail_screen.dart # Chi tiết sinh viên
│   ├── add_edit_student/
│   │   └── add_edit_student_screen.dart # Form thêm/sửa
│   ├── statistics/
│   │   └── statistics_screen.dart     # Thống kê với 3 tabs
│   └── home_screen.dart               # Tab bar navigation (optional)
│
├── services/
│   └── supabase_service.dart          # API calls - CRUD operations
│
├── widgets/
│   ├── common/
│   │   ├── filter_header_widget.dart  # Custom sticky filter header
│   │   ├── tuition_detail_dialog.dart # Dialog chi tiết học phí
│   │   └── student_card.dart          # Reusable student card widget
│   └── filters/
│       └── filter_bottom_sheet.dart   # Modal bottom sheet lọc
│
└── utils/
    └── animation_helper.dart          # Transition animations helper
```

---

### **2. State Management Architecture (Provider Pattern):**

#### **StudentProvider (ChangeNotifierProvider):**
```dart
// Properties:
- List<Student> students;              // Toàn bộ sinh viên từ DB
- List<Student> filteredStudents;      // Sau khi filter/search
- String searchQuery = '';
- String classFilter = '';
- String departmentFilter = '';
- double? gpaFilter;
- bool isLoading = false;
- String? errorMessage;

// Methods:
- Future<void> fetchStudents()         // Gọi API lấy danh sách
- Future<void> searchStudents(String query)  // Real-time search
- Future<void> filterStudents(...)     // Apply filter logic
- Future<void> addStudent(Student)     // Thêm mới
- Future<void> updateStudent(Student)  // Cập nhật
- Future<void> deleteStudent(String id) // Xóa
- void clearFilters()                  // Reset bộ lọc
- void notifyListeners()               // Notify UI
```

#### **ThemeProvider (ChangeNotifierProvider):**
```dart
// Properties:
- bool _isDarkMode = false;

// Methods:
- void toggleTheme()                   // Toggle dark/light
- ThemeData getThemeData()             // Return current theme
- void loadThemePreference()           // Load từ SharedPreferences
- void saveThemePreference()           // Save vào SharedPreferences
```

#### **Integration tại main.dart:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => StudentProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: Consumer<ThemeProvider>(
    builder: (ctx, themeProvider, _) => MaterialApp(
      theme: themeProvider.getThemeData(),  // Light theme
      darkTheme: themeProvider.getThemeData(),  // Dark theme
      // ... rest of app
    ),
  ),
)
```

---

### **3. Data Persistence & Hệ Thống Lưu Trữ:**

#### **SharedPreferences (Local Caching):**
- Lưu `isDarkMode` preference
- Lưu last search query (optional)
- Lưu filter preferences (optional)

#### **Database Layer (Supabase/Firebase):**
- **Supabase Tables:**
  - `students` table với fields: id, name, email, phone, address, gpa, class, department, dateOfBirth, gender
  - Real-time sync khi có changes
  
- **Supabase Service (supabase_service.dart):**
  ```dart
  - Future<List<Student>> getStudents()
  - Future<Student> getStudentById(String id)
  - Future<void> insertStudent(Student)
  - Future<void> updateStudent(Student)
  - Future<void> deleteStudent(String id)
  - Stream<List<Student>> getStudentsStream()  // Real-time updates
  ```

#### **Offline Support:**
- Implement local cache + sync logic
- Khi network available → Sync dữ liệu local với server
- Khi offline → Show cached data + indication

---

### **4. Form Validation & Error Handling (Chi Tiết):**

#### **Validation Rules:**
```dart
// Tên sinh viên
- required, min 2 chars, max 100 chars
- Pattern: Chỉ chứa chữ, số, khoảng trắng

// Email
- required, format email valid (regex)
- unique check (async validator từ DB)

// Số điện thoại
- required, format Việt Nam: 09x, 08x, 07x, etc
- 10 ký tự

// GPA
- required, number, 0.0 - 4.0

// Ngày sinh
- required, must be in past
- Age >= 18 (tuỳ quy định)

// Lớp, Khoa, Giới tính
- required dropdowns
```

#### **Error Handling:**
- Try-catch wrapper cho tất cả API calls
- Show user-friendly error messages (Tiếng Việt)
- Snackbar notifications (error, success, info)
- Retry logic cho failed operations
- Timeout handling (30s default)

---

### **5. Animations & Transitions (Chi Tiết):**

#### **AnimationHelper Class:**
```dart
- static PageRouteBuilder<T> createSlideTransition<T>(
    Widget page, 
    {Offset begin = const Offset(1, 0)}
  )
  → Slide từ phải vào (hoặc tùy begin)
  → Duration: 300ms
  → Curve: Curves.easeInOutQuad

- static PageRouteBuilder<T> createFadeTransition<T>(
    Widget page
  )
  → Fade in/out
  → Duration: 300ms
  → Curve: Curves.easeInOut

- static PageRouteBuilder<T> createScaleTransition<T>(
    Widget page
  )
  → Scale from 0.0 → 1.0
  → Duration: 300ms
  → Curve: Curves.elasticOut
```

#### **Usage:**
```dart
Navigator.push(
  context,
  AnimationHelper.createSlideTransition(
    const StudentDetailScreen(student: student),
  ),
)
```

#### **Built-in Animations:**
- **SliverAppBar:** Automatic collapse animation
- **Hero Animation:** Avatar expand trên detail screen
- **Dismissible:** Swipe-to-delete animation
- **Transitions:** Bottom sheet slide up, Dialog fade in
- **Button Ripple:** Material ink effect
- **Progress Bar:** Animated value change

---

### **6. UI/UX Best Practices Implementation:**

#### **Responsive Design:**
```dart
- MediaQuery.of(context).size untuk adaptive layout
- Flexible/Expanded widgets cho layouts
- FractionallySizedBox cho proportional sizing
- SingleChildScrollView (horizontal) cho tables
```

#### **Loading States:**
```dart
- CircularProgressIndicator (center)
- LinearProgressIndicator (bottom sheet loading)
- Shimmer effect (skeleton loading)
- Toast/Snackbar notifications
```

#### **Empty States:**
```dart
- Hiện icon neutral + descriptive text
- "Không có sinh viên" khi danh sách rỗng
- "Không tìm thấy kết quả" khi search empty
- Nút "Quay lại" hoặc "Thêm sinh viên"
```

#### **Error States:**
```dart
- Hiện error message + icon
- Retry button nếu network error
- Dialog để confirm delete
```

#### **Accessibility:**
```dart
- Semantics labels trên buttons
- Sufficient color contrast
- Font sizes >= 14sp cho text
- Button min size 48x48dp
- Proper touch targets
```

---

### **7. Code Quality Standards:**

#### **Null Safety:**
- Tất cả biến phải có type (non-null by default)
- Dùng `?` cho nullable types
- Dùng `late` cho delayed initialization

#### **Constants & Magic Numbers:**
- Tất cả hardcoded values → Constants file
- Repeated colors/sizes → Define globally
- Example: `AppConstants.primaryColor`, `AppConstants.paddingDefault`

#### **Code Organization:**
- 1 file = 1 class (chủ yếu)
- Private methods: prefix `_`
- Public methods/vars: no prefix
- Imports organized: dart → flutter → packages → local

#### **Documentation:**
- /// Doc comments cho public methods
- // TODO comments cho pending work
- Meaningful variable names (avoid a, b, c)

#### **Performance:**
- Const constructors nơi possible
- `const` widgets khi static
- Provider listeners ở level thích hợp (nhỏ nhất)
- Avoid rebuild toàn trang khi chỉ update 1 widget
- Image caching strategy

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  supabase_flutter: ^1.0.0
  fl_chart: ^0.60.0
  uuid: ^3.0.0
  intl: ^0.18.0
  shared_preferences: ^2.0.0
```

---

## 🚀 Getting Started

### Prerequisites:
- Flutter SDK >= 3.0
- Supabase account hoặc Firebase project
- Android Studio / Xcode / VS Code

### Installation:
```bash
# Clone project
git clone <project-url>
cd studentmanager

# Get dependencies
flutter pub get

# Run app
flutter run
```

---

## 📱 Các Tính Năng Chính

✅ Danh sách sinh viên với tìm kiếm & lọc  
✅ Chi tiết sinh viên + Tính toán học phí  
✅ Thống kê với biểu đồ (PieChart)  
✅ Thêm/Sửa/Xóa sinh viên  
✅ Theme Toggle (Dark/Light mode)  
✅ Animations mượt mà giữa các màn hình  
✅ State Management toàn ứng dụng (Provider)  
✅ Responsive design  

---

## 🎓 Kiến Thức Áp Dụng

- **UI/UX:** Material Design 3, SliverAppBar, Sticky widgets
- **State Management:** Provider, ChangeNotifier
- **Navigation:** Named routes, Hero Animation
- **Animations:** PageRoute transitions, Custom animations
- **API Integration:** Supabase/Firebase
- **Local Storage:** SharedPreferences
- **Data Persistence:** Database + Local caching
- **Form Validation:** TextFormField, validation rules
- **Charts:** fl_chart (PieChart, BarChart)

---

## 📝 Notes
- Tất cả text phải support tiếng Việt
- Định dạng tiền tệ: Tiền Việt Nam Đồng (VND)
- Màu sắc chủ đạo: Xanh dương (#2196F3), Tím (#7C3AED)
- Font chủ đạo: Roboto (default Flutter)
