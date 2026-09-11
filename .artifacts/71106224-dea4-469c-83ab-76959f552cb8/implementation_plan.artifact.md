# Refactor `map` feature to `hospital_finder`

This plan details the migration of the `map` feature to a more descriptively named `hospital_finder` feature. This includes directory renaming, file renaming, class/symbol renaming, and updating all internal and external references.

## Proposed Changes

### 1. File and Directory Migration

#### [NEW] `lib/src/features/hospital_finder/`
All files currently in `lib/src/features/map/` will be moved here.

#### [DELETE] `lib/src/features/map/`
The old feature directory will be removed after migration.

#### [RENAME] Internal Files
- `map_service.dart` -> `hospital_finder_service.dart`
- `map_cubit.dart` -> `hospital_finder_cubit.dart`
- `map_state.dart` -> `hospital_finder_state.dart`
- `map_page.dart` -> `hospital_finder_page.dart`
- `map_canvas_view.dart` -> `hospital_finder_canvas_view.dart`
- `map_quick_actions.dart` -> `hospital_finder_quick_actions.dart`
- `map_search_header.dart` -> `hospital_finder_search_header.dart`

### 2. Symbol and Class Renaming (Global)

- `MapService` -> `HospitalFinderService`
- `MapCubit` -> `HospitalFinderCubit`
- `MapState` -> `HospitalFinderState`
- `MapPage` -> `HospitalFinderPage`
- `MapCanvasView` -> `HospitalFinderCanvasView`
- `MapQuickActions` -> `HospitalFinderQuickActions`
- `MapSearchHeader` -> `HospitalFinderSearchHeader`

### 3. Router Configuration

#### [MODIFY] [route_names.dart](file:///C:/Users/thanhduy/Documents/GitHub/HealthLife/lib/src/shared/router/route_names.dart)
Update `RouteNames.map` to `RouteNames.hospitalFinder`.

#### [MODIFY] [app_router.dart](file:///C:/Users/thanhduy/Documents/GitHub/HealthLife/lib/src/shared/router/app_router.dart)
Update the route definition and imports to use the new `HospitalFinderPage` and path.

### 4. Import Updates
Update all project files that import from `package:healthlife/src/features/map/...` to `package:healthlife/src/features/hospital_finder/...`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no broken imports or missing symbols.
- Build the project to verify successful compilation.

### Manual Verification
- Verify navigation to the "Hospital Finder" feature via the router.
- Verify that map markers, search, and quick actions still function correctly under the new naming.
