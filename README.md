# Kinetic Solutions Limited — Business Management System

## Tech stack
| Layer | Package |
|---|---|
| Framework | Flutter 3.44.4 / Dart 3.12.1 |
| Platforms | Web (Chrome) + Windows Desktop |
| Local DB | hive_flutter 1.1.0 |
| Charts | fl_chart 0.70.2 |
| State | flutter_bloc 8.1.6 |
| Barcode scan | mobile_scanner 5.2.3 |
| Photo/camera | image_picker 1.1.2 |
| HTTP | dio 5.7.0 |
| IDs | uuid 4.5.1 |

## Getting started

```bash
flutter pub get
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop
flutter build web              # Production web build
flutter build windows          # Production Windows build
```

## Default login
```
Email:    admin@kineticsolutions.zm
Password: Admin@123
```
> Change this immediately after first login via Settings → Users.

## Add your logo
Replace the `'KSL'` text placeholder in:
- `lib/presentation/pages/login_page.dart` → `_Logo` widget
- `lib/presentation/pages/dashboard_page.dart` → `_Sidebar` widget

With:
```dart
Image.asset('assets/images/logo.png', width: 36, height: 36, fit: BoxFit.contain)
```
Then place your logo PNG at `assets/images/logo.png`.

## File structure
```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart   # VAT, PAYE, NAPSA, currency
│   └── theme/app_theme.dart           # Material 3 theme
├── data/
│   └── datasources/local_database.dart  # Hive CRUD + auth
├── domain/
│   └── entities/
│       ├── app_user.dart              # User + roles
│       ├── inventory_item.dart        # Stock + VAT calc
│       ├── employee.dart              # PAYE + NAPSA calc
│       ├── customer.dart              # TPIN + credit
│       ├── project.dart               # Budget + risk
│       └── task.dart                  # Priority + status
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   ├── dashboard_page.dart        # Sidebar + topbar shell
    │   ├── inventory_list_page.dart
    │   ├── inventory_form_page.dart   # Barcode scan + photo upload
    │   ├── stock_in_page.dart
    │   ├── stock_out_page.dart
    │   ├── employee_list_page.dart
    │   ├── employee_form_page.dart    # Live PAYE/NAPSA preview
    │   ├── project_list_page.dart
    │   ├── project_form_page.dart
    │   ├── project_detail_page.dart   # Tasks + milestones tabs
    │   └── task_form_page.dart
    └── widgets/
        └── shared_widgets.dart

## User roles
| Role | Inventory | Staff | Clients | Projects | Finance | Reports | Users |
|---|---|---|---|---|---|---|---|
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Manager | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| Staff | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Finance | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| Viewer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

## Zambian compliance built in
- **VAT**: 16% auto-calculated on vatable items (ZRA rate)
- **PAYE**: Progressive bands 0% / 25% / 30% / 37.5% (live preview in employee form)
- **NAPSA**: 5% capped at ZMW 1,164.40/month
- **NRC**: National Registration Card tracked per employee
- **TPIN**: Taxpayer Identification Number tracked per customer
- **Currency**: Zambian Kwacha (ZMW / K) throughout

## Next modules to build
- [ ] Customer list + form pages
- [ ] Financial management (invoices, expenses, P&L)
- [ ] Reports page (inventory, payroll, project analytics)
- [ ] User management page (Admin only)
- [ ] Milestones management
- [ ] Mobile Money integration (Airtel Money, MTN Money)
- [ ] PDF export for reports and invoices
- [ ] Cloud sync / backup
